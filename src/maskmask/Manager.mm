//
//  MaskMask.cpp
//  MaskMask
//
//  Created by Brett Renfer on 5/14/15.
//
//

#include "Manager.h"

namespace mm {
    
#pragma mark Manager
    
    //--------------------------------------------------------------
    Manager::Manager(){
        currentMode = MODE_ADD; // todo: should be tied to a "first time" setting
        bNeedToResize = false;
        bAddCursor = false;
        currentShape = nullptr;
    }
    
    //--------------------------------------------------------------
    Manager::~Manager(){
        ofRemoveListener(statusMenu.onSave, this, &Manager::onSave);
        ofRemoveListener(statusMenu.onReload, this, &Manager::onReload);
        ofRemoveListener(statusMenu.onToggleMode, this, &Manager::onMode);
        
//        ofRemoveListener(//toolBar.onChangeTool, this, &Manager::onChangeMode);
        
        ofRemoveListener(ofEvents().update, this, &Manager::update);
        ofRemoveListener(ofEvents().draw, this, &Manager::draw);
        
        ofRemoveListener(ofEvents().keyPressed, this, &Manager::keyPressed);
        ofRemoveListener(ofEvents().mousePressed, this, &Manager::mousePressed);
        ofRemoveListener(ofEvents().mouseDragged, this, &Manager::mouseDragged);
        ofRemoveListener(ofEvents().mouseReleased, this, &Manager::mouseReleased);
        ofRemoveListener(ofEvents().mouseMoved, this, &Manager::mouseMoved);
    }
    
    //--------------------------------------------------------------
    void Manager::setup(){
        // build task bar
        statusMenu.setup();
        ofAddListener(statusMenu.onSave, this, &Manager::onSave);
        ofAddListener(statusMenu.onReload, this, &Manager::onReload);
        ofAddListener(statusMenu.onToggleMode, this, &Manager::onMode);
        
        // build tool bar
//        //toolBar.setup();
//        ofAddListener(//toolBar.onChangeTool, this, &Manager::onChangeMode);
        
        // build cursor images
        @autoreleasepool {
            NSImage *addImage, *delImage, *editImageA, *editImageB;
            addImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:ofToDataPath("cursors/cursor_add.pdf").c_str()]];
            delImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:ofToDataPath("cursors/cursor_delete.pdf").c_str()]];
            editImageA = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:ofToDataPath("cursors/cursor_edit.pdf").c_str()]];
            editImageB = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:ofToDataPath("cursors/cursor_edit_m.pdf").c_str()]];
            
            cursorStandard = [NSCursor arrowCursor];
            cursorAdd = [[NSCursor alloc] initWithImage:addImage hotSpot:NSMakePoint(0,0) ];
            cursorEditA = [[NSCursor alloc] initWithImage:editImageA hotSpot:NSMakePoint(0,0) ];
            cursorEditD = [[NSCursor alloc] initWithImage:editImageB hotSpot:NSMakePoint(0,0) ];
            cursorDel = [[NSCursor alloc] initWithImage:delImage hotSpot:NSMakePoint(0,0) ];
        }
    
        // load settings
        onReload();
        
        // load render shader
        renderShader.load("", ofToDataPath("shaders/render.frag"));
        renderFbo.allocate(ofGetWidth(), ofGetHeight(), GL_RGBA, 0);
        
        // get this show on the road
        ofAddListener(ofEvents().update, this, &Manager::update);
        ofAddListener(ofEvents().draw, this, &Manager::draw);
        
        ofAddListener(ofEvents().keyPressed, this, &Manager::keyPressed);
        ofAddListener(ofEvents().mousePressed, this, &Manager::mousePressed);
        ofAddListener(ofEvents().mouseDragged, this, &Manager::mouseDragged);
        ofAddListener(ofEvents().mouseReleased, this, &Manager::mouseReleased);
        ofAddListener(ofEvents().mouseMoved, this, &Manager::mouseMoved);
        
        setMode(currentMode);
    }
    
    //--------------------------------------------------------------
    void Manager::update(ofEventArgs & e ){
        if ( bNeedToResize ){
            renderFbo.allocate(ofGetWidth(), ofGetHeight(), GL_RGBA, 0);
        }
        
        // clean up shapes
        for ( auto & it : shapes ){
            if (it.second->shouldDelete() ){
                shapes.erase(it.first);
                break;
            }
        }
    }
    
    //--------------------------------------------------------------
    void Manager::draw(ofEventArgs & e ){
        renderFbo.begin();
        ofClear(0);
        ofSetColor(255);
        
        // mode-specific zones
        switch( currentMode ){
            case MODE_WELCOME:
                break;
            case MODE_ADD:
                break;
            case MODE_RENDER:
                break;
            case MODE_EDIT:
                break;
            case MODE_EDIT_DEL:
                break;
        }
        
        // toolbar
        if ( currentMode >= MODE_ADD ){
//            //toolBar.draw();
        }
        
        if ( shapes.size() > 0 ){
            for ( auto & it : shapes ){
                it.second->draw( currentMode );
            }
        }
        renderFbo.end();
        
        ofSetColor(255);
        renderShader.begin();
        renderShader.setUniform1i("mode", (int) currentMode );
        renderShader.setUniform4f("ko_color", SHAPE_COLOR.r/255.f,SHAPE_COLOR.g/255.f,SHAPE_COLOR.b/255.f,SHAPE_COLOR.a/255.f );
        renderShader.setUniformTexture("tex0", renderFbo.getTexture(0), 0);
        renderFbo.draw(0,0);
        renderShader.end();
    }
    
    //--------------------------------------------------------------
    // shape methods
    //--------------------------------------------------------------
    
    //--------------------------------------------------------------
    int Manager::createShape(){
        int nid = shapes.size();
        
        while (shapes.size() != 0 && shapes.count(nid) != 0 ){
            nid++;
        }
        shapes[nid] = new Shape();
        
        return nid;
    }
    
    //--------------------------------------------------------------
    void Manager::removeShape( int shapeId ){
        
    }
    
    //--------------------------------------------------------------
    Shape & getShape( int shapeId ){
        
    }
    
    //--------------------------------------------------------------
    // Window methods
    //--------------------------------------------------------------
    
    //--------------------------------------------------------------
    void Manager::keyPressed( ofKeyEventArgs & e ){
        
        // major key combos
        if ( e.key == OF_KEY_TAB ){
            onMode();
            return;
        } if ( ofGetKeyPressed( OF_KEY_SUPER )){
            if ( e.key == 's' ){
                onSave();
            } else if ( e.key == 'z' ){
                if (currentShape != nullptr && currentMode >= MODE_ADD ){
                    currentShape->removeLastVertex();
                }
            }
        }
        
        // mode stuff
        switch (currentMode) {
            case MODE_WELCOME:
                break;
            case MODE_EDIT:
            {
                if ( e.key == OF_KEY_DEL || e.key == OF_KEY_BACKSPACE ){
                    if ( shapes.size() > 0 ){
                        for ( auto & it : shapes ){
                            it.second->deleteSelected();
                        }
                    }
                }
            }
                break;
                
            case MODE_ADD:
            {
                if ( e.key == OF_KEY_RETURN){
                    setMode(MODE_EDIT);
                }
            }
                break;
                
                
            case MODE_RENDER:
                break;
        }
    }
    
    //--------------------------------------------------------------
    void Manager::mousePressed( ofMouseEventArgs & e ){
        
        // toolbar stuff
        if ( currentMode >= MODE_ADD ){
//            if( //toolBar.mousePressed(e) ){
//                return;
//            }
        }
        
        switch (currentMode) {
            case MODE_WELCOME:
                break;
            case MODE_ADD:
                if ( currentShape != nullptr ){
                    unique_lock<mutex> lock(mux);
                    
                    if ( currentShape != nullptr ){
                        currentShape->addVertex(e);
                    }
                } else {
                    bool bFound = false;
                    if ( shapes.size() > 0 ){
                        for ( auto & it : shapes ){
                            if ( it.second->mousePressed(e, currentMode) ){
                                currentShape = it.second;
                                bFound = true;
                                break;
                            }
                        }
                    }
                    if ( !bFound ){
                        
                        currentShape = shapes[createShape()];
                    }
                }
                break;
                
            case MODE_EDIT:
            case MODE_EDIT_DEL:                
                if ( shapes.size() > 0 ){
                    for ( auto & it : shapes ){
                        if ( it.second->mousePressed(e, currentMode) ) break;
                    }
                }
                break;
                
            case MODE_RENDER:
                break;
        }
    }
    
    //--------------------------------------------------------------
    void Manager::mouseDragged( ofMouseEventArgs & e ){
        switch (currentMode) {
            case MODE_WELCOME:
                break;
            case MODE_ADD:
                if ( shapes.size() > 0 ){
                    for ( auto & it : shapes ){
                        it.second->mouseDragged(e, currentMode);
                    }
                }
                break;
                
            case MODE_EDIT:
                if ( shapes.size() > 0 ){
                    for ( auto & it : shapes ){
                        it.second->mouseDragged(e);
                    }
                }
                break;
                
            case MODE_RENDER:
                break;
        }
        // toolbar stuff
        if ( currentMode >= MODE_ADD ){
            //toolBar.mouseDragged(e);
        }
    }
    
    //--------------------------------------------------------------
    void Manager::mouseReleased( ofMouseEventArgs & e ){
        switch (currentMode) {
            case MODE_WELCOME:
                break;
            case MODE_ADD:
                break;
                
            case MODE_EDIT:
                if ( shapes.size() > 0 ){
                    for ( auto & it : shapes ){
                        it.second->mouseReleased(e);
                    }
                }
                break;
                
            case MODE_RENDER:
                break;
        }
        
        // toolbar stuff
        if ( currentMode >= MODE_ADD ){
            //toolBar.mouseReleased(e);
        }
    }
    
    //--------------------------------------------------------------
    void Manager::mouseMoved( ofMouseEventArgs & e ){
        switch (currentMode) {
            case MODE_WELCOME:
                break;
            case MODE_ADD:
                if ( currentShape != nullptr ){
                    currentShape->setNextPoint(e);
                }
                break;
                
            case MODE_EDIT_DEL:
            case MODE_EDIT:
                if ( shapes.size() > 0 ){
                    for ( auto & it : shapes ){
                        it.second->mouseMoved(e, currentMode);
                    }
                }
                break;
                
            case MODE_RENDER:
                break;
        }
        
        // toolbar stuff
        if ( currentMode >= MODE_ADD ){
            //toolBar.mouseMoved(e);
        }
    }
    
    //--------------------------------------------------------------
    void Manager::windowResized( ofResizeEventArgs & e ){
        bNeedToResize = true;
    }
    
    //--------------------------------------------------------------
    // Menu event methods
    //--------------------------------------------------------------
    
    //--------------------------------------------------------------
    void Manager::onSave(){
        ofXml xmlOut;
        xmlOut.addChild("shapes");
        xmlOut.setToChild(0);
        
        int child = 0;
        
        for ( auto & s : shapes ){
            xmlOut.addChild("shape");
            xmlOut.setToChild(child);
            int index = 0;
            for ( auto & p : s.second->getPoints()){
                xmlOut.addChild("point");
                xmlOut.setToChild(index);
                xmlOut.addValue("x", p.x);
                xmlOut.addValue("y", p.y);
                xmlOut.addValue("isBezier", p.bUseBezier);
                xmlOut.addValue("b1x", p.bezierA.x);
                xmlOut.addValue("b1y", p.bezierA.y);
                xmlOut.addValue("b2x", p.bezierB.x);
                xmlOut.addValue("b2y", p.bezierB.y);
                xmlOut.setToParent();
                
                index++;
            }
            xmlOut.setToParent();
            child++;
        }
        
        if ( !ofDirectory(ofToDataPath("settings")).exists() ){
            ofDirectory dir(ofToDataPath("settings"));
            dir.create();
        }
        xmlOut.save(ofToDataPath("settings/settings.xml"));
    }
    
    //--------------------------------------------------------------
    void Manager::onReload(){
        ofXml xml;
        if ( xml.load(ofToDataPath("settings/settings.xml"))){
//            xml.setToChild(0);
            int nShapes = xml.getNumChildren();
            for ( int i=0; i<nShapes; i++){
                createShape();
            }
            
            int shapeIndex = 0;
            for ( auto & s : shapes ){
                xml.setToChild(shapeIndex);
                
                int vIndex = 0;
                int nVerts = xml.getNumChildren();
                for ( int i=0; i<nVerts; i++){
                    xml.setToChild(i);
                    
                    float x = xml.getValue("x", 0.f);
                    float y = xml.getValue("y", 0.f);
                    s.second->addVertex(ofVec2f(x,y));
                    
                    x = xml.getValue("b1x", 0.);
                    y = xml.getValue("b1y", 0.);
                    s.second->getPoints()[i].bezierA.set(x,y);
                    x = xml.getValue("b2x", 0.);
                    y = xml.getValue("b2y", 0.);
                    s.second->getPoints()[i].bezierB.set(x,y);
                    s.second->getPoints()[i].bUseBezier = xml.getValue("isBezier", false);
                    xml.setToParent();
                }
                
                xml.setToParent();
                currentShape = s.second;
            }
            xml.setToParent();
        }
    }
    
    //--------------------------------------------------------------
    void Manager::onMode(){
        Mode newMode = (Mode)(currentMode + 1);
        if ( newMode > MODE_EDIT ){
            newMode = MODE_RENDER;
            rc::setWindowLevel(NSScreenSaverWindowLevel);
            rc::cocoaWindow()->setWindowPosition(0,0);
            
            for ( auto & s : shapes ){
                auto & p = s.second->getPoints();
                for (auto & v : p ){
                    v.y += 50;
                }
            }
        } else if ( newMode == MODE_ADD ){
            rc::setWindowLevel(NSMainMenuWindowLevel);
            rc::cocoaWindow()->setWindowPosition(0,50);
            
            for ( auto & s : shapes ){
                auto & p = s.second->getPoints();
                for (auto & v : p ){
                    v.y -= 50;
                }
            }
        }
        setMode(newMode);
    }
    
    //--------------------------------------------------------------
    void Manager::onChangeMode( Mode & m ){
        setMode(m);
    }
    
    //--------------------------------------------------------------
    // Mode methods
    //--------------------------------------------------------------
    
    //--------------------------------------------------------------
    void Manager::setMode( Mode newMode ){
    
        currentMode = newMode;
        
        switch (newMode) {
            case MODE_WELCOME:
                break;
            case MODE_EDIT:
                if ( currentShape != nullptr ){
                    currentShape->close();
                    currentShape = nullptr;
                }
                
                
                
                [rc::glWindow() setIgnoresMouseEvents:NO];
                [rc::glView() addCursorRect:rc::rectForAllScreens() cursor:cursorEditA];
                [cursorEditA set];
                break;
            case MODE_ADD:
                [rc::glWindow() setIgnoresMouseEvents:NO];
                [rc::glView() addCursorRect:rc::rectForAllScreens() cursor:cursorAdd];
                [cursorAdd set];
                break;
                
            case MODE_RENDER:
                currentShape = nullptr;
                [rc::glWindow() setIgnoresMouseEvents:YES];
                
                [rc::glView() addCursorRect:rc::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                break;
        }
        
        // set cursor
        switch (currentMode) {
            case MODE_WELCOME:
                [rc::glView() addCursorRect:rc::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                break;
            case MODE_EDIT:
                [rc::glView() addCursorRect:rc::rectForAllScreens() cursor:cursorEditA];
                [cursorEditA set];
                break;
                
            case MODE_EDIT_DEL:
                [rc::glView() addCursorRect:rc::rectForAllScreens() cursor:cursorEditD];
                [cursorEditD set];
                break;
                
            case MODE_ADD:
                [rc::glView() addCursorRect:rc::rectForAllScreens() cursor:cursorAdd];
                [cursorAdd set];
                break;
                
            case MODE_RENDER:
                [rc::glView() addCursorRect:rc::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                break;
        }
    }
}