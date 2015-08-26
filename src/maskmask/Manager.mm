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
        externalMouseEventsActive = false;
        maxAlpha = 0.;
    }
    
    //--------------------------------------------------------------
    Manager::~Manager(){
        ofRemoveListener(statusMenu.onSave, this, &Manager::onSave);
        ofRemoveListener(statusMenu.onReload, this, &Manager::onReload);
        ofRemoveListener(statusMenu.onToggleMode, this, &Manager::onMode);
        
//        ofRemoveListener(//toolBar.onChangeTool, this, &Manager::onChangeMode);
        
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
        ofAddListener(ofEvents().keyPressed, this, &Manager::keyPressed);
        ofAddListener(ofEvents().mousePressed, this, &Manager::mousePressed);
        ofAddListener(ofEvents().mouseDragged, this, &Manager::mouseDragged);
        ofAddListener(ofEvents().mouseReleased, this, &Manager::mouseReleased);
        ofAddListener(ofEvents().mouseMoved, this, &Manager::mouseMoved);
        
        setMode(currentMode);
    }
    
    //--------------------------------------------------------------
    void Manager::setAndConfigureWindow( NSWindow * window, NSView * view ){
        this->window = window;
        this->glView = view;
        
        [this->window setStyleMask:NSBorderlessWindowMask];
        [this->window setLevel:NSMainMenuWindowLevel];
        [this->window setHasShadow:NO];
        [this->window setBackgroundColor:[NSColor clearColor]];
        [this->window setOpaque:NO];
        [this->window setIgnoresMouseEvents:YES];
        NSRect rect = rc::rectForAllScreens();
        [this->window setFrame:rect display:YES ];
    }
    
    //--------------------------------------------------------------
    void Manager::update( ){
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
    void Manager::draw( ){
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
                maxAlpha = maxAlpha * .9 + MM_RENDER_ALPHA * .1;
                break;
                
            case MODE_RENDER_PREVIEW:
                maxAlpha = maxAlpha * .9 + MM_RENDER_PREVIEW_ALPHA * .1;
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
        renderShader.setUniform1f("maxAlpha", maxAlpha);
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
            case MODE_RENDER_PREVIEW:
                for ( auto & it : shapes ){
                    if ( it.second->inside( e, currentMode ) ){
                        setMode(MODE_RENDER);
                        break;
                    }
                }
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
        }
//
//            [window setLevel:NSScreenSaverWindowLevel];
////            rc::setWindowPosition( window, glView, ofPoint(0,0));
////            
////            for ( auto & s : shapes ){
////                auto & p = s.second->getPoints();
////                for (auto & v : p ){
////                    v.y += 50;
////                }
////            }
//        } else if ( newMode == MODE_ADD ){
//            [window setLevel:NSMainMenuWindowLevel];
////            rc::setWindowPosition( window, glView, ofPoint(0,50));
////            
////            for ( auto & s : shapes ){
////                auto & p = s.second->getPoints();
////                for (auto & v : p ){
////                    v.y -= 50;
////                }
////            }
//        }
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
                
                setExternalMouse(false);
                [window setIgnoresMouseEvents:NO];
                [glView addCursorRect:rc::rectForAllScreens() cursor:cursorEditA];
                [cursorEditA set];
                [window setLevel:NSMainMenuWindowLevel];
                break;
                
            case MODE_ADD:
                setExternalMouse(false);
                [window setIgnoresMouseEvents:NO];
                [glView addCursorRect:rc::rectForAllScreens() cursor:cursorAdd];
                [cursorAdd set];
                [window setLevel:NSMainMenuWindowLevel];
                break;
                
            case MODE_RENDER:
                currentShape = nullptr;
                [window setIgnoresMouseEvents:YES];
                setExternalMouse(true);
                
                [glView addCursorRect:rc::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                [window setLevel:NSScreenSaverWindowLevel];
                break;
            
            case MODE_RENDER_PREVIEW:
                currentShape = nullptr;
                [window setIgnoresMouseEvents:NO];
                
                [glView addCursorRect:rc::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                [window setLevel:NSMainMenuWindowLevel];
                break;
        }
        
        // set cursor
        switch (currentMode) {
            case MODE_WELCOME:
                [glView addCursorRect:rc::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                break;
            case MODE_EDIT:
                [glView addCursorRect:rc::rectForAllScreens() cursor:cursorEditA];
                [cursorEditA set];
                break;
                
            case MODE_EDIT_DEL:
                [glView addCursorRect:rc::rectForAllScreens() cursor:cursorEditD];
                [cursorEditD set];
                break;
                
            case MODE_ADD:
                [glView addCursorRect:rc::rectForAllScreens() cursor:cursorAdd];
                [cursorAdd set];
                break;
                
            case MODE_RENDER:
                [glView addCursorRect:rc::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                break;
        }
    }
    
    
    //--------------------------------------------------------------
    // UTILS
    //--------------------------------------------------------------
    
    void Manager::mouseDownOutside( NSEvent * theEvent) {
        ofMouseEventArgs args;
        ofPoint p = rc::ofPointFromOutsideEvent(glView, theEvent);
        for ( auto & it : shapes ){
            if ( it.second->inside( p, currentMode ) ){
                setMode(MODE_RENDER_PREVIEW);
                break;
            }
        }
    }
    
    void Manager::setExternalMouse( bool bOn ){
        if (bOn){
            
            leftMouseDownHandler	= [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent * mouseEvent) {
                mouseDownOutside(mouseEvent);
            }];
            
            externalMouseEventsActive = true;
        } else if (externalMouseEventsActive) {
            [NSEvent removeMonitor:leftMouseDownHandler];
            leftMouseDownHandler = nil;
            externalMouseEventsActive = false;
        }
    }
}