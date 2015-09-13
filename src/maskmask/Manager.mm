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
        bNeedToShowTools = false;
        currentShape = nullptr;
        externalMouseEventsActive = false;
        maxAlpha = 0.;
        debugColor.set(SHAPE_COLOR);
    }
    
    //--------------------------------------------------------------
    Manager::~Manager(){
        ofRemoveListener(statusMenu.onSave, this, &Manager::onSave);
        ofRemoveListener(statusMenu.onReload, this, &Manager::onReload);
        ofRemoveListener(statusMenu.onToggleMode, this, &Manager::onMode);
        
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
        
        // build tutorial
        bool doTutorial = tutorialMgr.setup();
        if (doTutorial){
            currentMode = MODE_WELCOME;
            ofAddListener(tutorialMgr.onShowTools, this, &Manager::showTools);
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
        
        ofAddListener(mm::Events::get().modeChanged, this, &Manager::onChangeMode);
        ofNotifyEvent( mm::Events::get().modeChanged, currentMode, this );
    }
    
    //--------------------------------------------------------------
    void Manager::setAndConfigureWindow( NSWindow * window, NSView * view ){
        this->window = window;
        this->glView = view;
        
        [this->window setStyleMask:NSBorderlessWindowMask];
        [this->window setLevel:NSFloatingWindowLevel];
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
            case MODE_WELCOME:{
                bool bKeepGoing = tutorialMgr.draw();
                if ( !bKeepGoing ){
                    Mode newMode = MODE_ADD;
                    ofNotifyEvent( mm::Events::get().modeChanged, newMode, this );
                }
            }
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
        if ( currentMode != MODE_WELCOME ){
            if ( shapes.size() > 0 ){
                for ( auto & it : shapes ){
                    it.second->draw( currentMode );
                }
            }
        }
        renderFbo.end();
        
        ofSetColor(255);
        renderShader.begin();
        renderShader.setUniform1f("maxAlpha", maxAlpha);
        renderShader.setUniform1i("mode", (int) currentMode );
        renderShader.setUniform4f("ko_color", debugColor.r/255.f,debugColor.g/255.f,debugColor.b/255.f,debugColor.a/255.f );
        renderShader.setUniformTexture("tex0", renderFbo.getTexture(0), 0);
        renderFbo.draw(0,0);
        renderShader.end();
    }
    
    //--------------------------------------------------------------
    // shape methods
    //--------------------------------------------------------------
    
    
    void Manager::setDebugColor( ofColor & c ){
        debugColor.set(c);
        
        for ( auto & it : shapes ){
            it.second->setFillColor(debugColor);
        }
        
        cout << debugColor << endl;
    }
    
    //--------------------------------------------------------------
    int Manager::createShape(){
        int nid = shapes.size();
        
        while (shapes.size() != 0 && shapes.count(nid) != 0 ){
            nid++;
        }
        shapes[nid] = new Shape();
        shapes[nid]->setFillColor(debugColor);
        
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
                    Mode newMode = MODE_EDIT;
                    ofNotifyEvent( mm::Events::get().modeChanged, newMode, this );
                }
            }
                break;
                
                
            case MODE_RENDER:
                break;
        }
    }
    
    //--------------------------------------------------------------
    void Manager::mousePressed( ofMouseEventArgs & e ){
        switch (currentMode) {
            case MODE_WELCOME:
                tutorialMgr.next();
                break;
            case MODE_ADD:
                if ( currentShape != nullptr ){
                    unique_lock<mutex> lock(mux);
                    
                    if ( currentShape != nullptr ){
                        bool bFound = false;
                        if ( currentShape->mousePressed(e, currentMode) ){
                            bFound = true;
                        }
                        
                        if ( !bFound ) currentShape->addVertex(e);
                        else {
                            auto * p = currentShape->getSelected();
                            if ( p == &currentShape->getPoints()[0] ){
                                Mode newMode = MODE_EDIT;
                                ofNotifyEvent( mm::Events::get().modeChanged, newMode, this );
                            }
                        }
                    }
                } else {
                    currentShape = shapes[createShape()];
                    currentShape->addVertex(e);
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
                        Mode newMode = MODE_RENDER;
                        ofNotifyEvent( mm::Events::get().modeChanged, newMode, this );
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
                if ( shapes.size() > 0 && currentShape == nullptr ){
                    for ( auto & it : shapes ){
                        it.second->mouseDragged(e, currentMode);
                    }
                } else {
                    currentShape->mouseDragged(e, currentMode);
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
            case MODE_RENDER_PREVIEW:
            case MODE_EDIT_DEL:
                break;
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
            case MODE_RENDER_PREVIEW:
            case MODE_EDIT_DEL:
                break;
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
            case MODE_RENDER_PREVIEW:
                break;
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
    void Manager::save(){
        auto & settings = Settings::get();
        
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
        
        xmlOut.save(ofToDataPath(settings.settingsFile));
    }
    
    //--------------------------------------------------------------
    void Manager::saveAs( string dest ){
        Settings::get().settingsFile = dest;
        Settings::get().save();
        save();
    }
    
    //--------------------------------------------------------------
    void Manager::reload(){
        shapes.clear();
        
        auto & settings = Settings::get();
        load( settings.settingsFile );
    }
    
    //--------------------------------------------------------------
    void Manager::load( string settings ){
        ofXml xml;
        if ( xml.load(ofToDataPath(settings))){
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
                shapeIndex++;
            }
            xml.setToParent();
        }
    }
    
    //--------------------------------------------------------------
    void Manager::onSave(){
        save();
    }
    
    //--------------------------------------------------------------
    void Manager::onReload(){
        reload();
    }
    
    //--------------------------------------------------------------
    void Manager::onMode(){
        Mode newMode = (Mode)(currentMode + 1);
        if ( newMode > MODE_EDIT ){
            newMode = MODE_RENDER;
        }
        ofNotifyEvent( mm::Events::get().modeChanged, newMode, this );
    }
    
    //--------------------------------------------------------------
    void Manager::onChangeMode( Mode & m ){
        setMode(m);
        [glView onChangeMode:m];
    }
    
    
    //--------------------------------------------------------------
    void Manager::showTools(){
        bNeedToShowTools = true;
    }
    
    //--------------------------------------------------------------
    bool Manager::getShowTools(){
        bool ret = bNeedToShowTools;
        bNeedToShowTools = false; // turn it off
        return ret;
    }
    
    //--------------------------------------------------------------
    // Mode methods
    //--------------------------------------------------------------
    
    //--------------------------------------------------------------
    void Manager::setMode( Mode newMode ){
    
        currentMode = newMode;
        
        // all new modes: finish shape if there is one
        
        if ( currentShape != nullptr ){
            bool bCloseable = currentShape->close();
            if ( !bCloseable ){
                for ( auto & it : shapes ){
                    if ( it.second == currentShape ){
                        shapes.erase(it.first);
                        break;
                    }
                }
            }
            currentShape = nullptr;
        }
        
        switch (newMode) {
            case MODE_WELCOME:
                setExternalMouse(false);
                [window setIgnoresMouseEvents:NO];
                CursorManager::get().setCursor(glView, CURSOR_STANDARD);
                [window setLevel:NSFloatingWindowLevel];
                break;
            case MODE_EDIT:
            case MODE_EDIT_DEL:
                
                setExternalMouse(false);
                [window setIgnoresMouseEvents:NO];
                CursorManager::get().setCursor(glView, CURSOR_EDIT);
                [window setLevel:NSFloatingWindowLevel];
                break;
                
            case MODE_ADD:
                setExternalMouse(false);
                [window setIgnoresMouseEvents:NO];
                
                CursorManager::get().setCursor(glView, CURSOR_ADD);
                [window setLevel:NSFloatingWindowLevel];
                break;
                
            case MODE_RENDER:
                currentShape = nullptr;
                [window setIgnoresMouseEvents:YES];
                setExternalMouse(true);
                
                CursorManager::get().setCursor(glView, CURSOR_STANDARD);
                [window setLevel:NSScreenSaverWindowLevel];
                break;
            
            case MODE_RENDER_PREVIEW:
                currentShape = nullptr;
                //[window setIgnoresMouseEvents:NO];
                
                CursorManager::get().setCursor(glView, CURSOR_STANDARD);
                [window setLevel:NSFloatingWindowLevel];
                break;
        }
    }
    
    //--------------------------------------------------------------
    // UTILS
    //--------------------------------------------------------------
    
    void Manager::mouseDownOutside( NSEvent * theEvent) {
        ofMouseEventArgs args;
        ofPoint p = rc::ofPointFromOutsideEvent(glView, theEvent);
        
        switch (currentMode) {
            case MODE_RENDER_PREVIEW:
                for ( auto & it : shapes ){
                    if ( it.second->inside( p, currentMode ) ){
                        setMode(MODE_RENDER);
                        break;
                    }
                }
                break;
                
            case MODE_RENDER:
            {
                bool bGood = true;
                for ( auto & it : shapes ){
                    if ( it.second->inside( p, currentMode ) ){
                        bGood = false;
                    }
                }
                if ( bGood ){
                    setMode(MODE_RENDER_PREVIEW);
                }
            }
                break;
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