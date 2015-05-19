//
//  MaskMask.cpp
//  MaskMask
//
//  Created by Brett Renfer on 5/14/15.
//
//

#include "Manager.h"
#include "ofxCocoa.h"

namespace mm {
    
#pragma mark Manager
    
    //--------------------------------------------------------------
    Manager::Manager(){
        currentMode = MODE_ADD; // todo: should be tied to a "first time" setting
        bNeedToResize = false;
        bAddCursor = false;
    }
    
    //--------------------------------------------------------------
    Manager::~Manager(){
        ofRemoveListener(statusMenu.onSave, this, &Manager::onSave);
        ofRemoveListener(statusMenu.onReload, this, &Manager::onReload);
        ofRemoveListener(statusMenu.onToggleMode, this, &Manager::onMode);
        
        ofRemoveListener(toolBar.onChangeTool, this, &Manager::onChangeMode);
        
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
        toolBar.setup();
        ofAddListener(toolBar.onChangeTool, this, &Manager::onChangeMode);
        
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
        mux.lock();
        for ( auto & it : shapes ){
            if (it.second.shouldDelete() ){
                shapes.erase(it.first);
                break;
            }
        }
        mux.unlock();
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
            toolBar.draw();
        }
        
        if ( shapes.size() > 0 ){
            for ( auto & it : shapes ){
                it.second.draw( currentMode );
            }
        }
        renderFbo.end();
        
        ofSetColor(255);
        renderShader.begin();
        renderShader.setUniform1i("mode", (int) currentMode );
        renderShader.setUniform4f("ko_color", SHAPE_COLOR.r/255.f,SHAPE_COLOR.g/255.f,SHAPE_COLOR.b/255.f,SHAPE_COLOR.a/255.f );
        renderShader.setUniformTexture("tex0", renderFbo.getTextureReference(0), 0);
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
        shapes[nid] = Shape();
        
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
        switch (currentMode) {
            case MODE_WELCOME:
                break;
            case MODE_EDIT:
            {
                if ( e.key == OF_KEY_DEL || e.key == OF_KEY_BACKSPACE ){
                    if ( shapes.size() > 0 ){
                        for ( auto & it : shapes ){
                            it.second.deleteSelected();
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
            if( toolBar.mousePressed(e) ){
                return;
            }
        }
        
        switch (currentMode) {
            case MODE_WELCOME:
                break;
            case MODE_ADD:
                if ( currentShape != NULL ){
                    currentShape->addVertex(e);
                } else {
                    bool bFound = false;
                    if ( shapes.size() > 0 ){
                        for ( auto & it : shapes ){
                            if ( it.second.mousePressed(e) ){
                                currentShape = &it.second;
                                bFound = true;
                                break;
                            }
                        }
                    }
                    if ( !bFound ){
                        currentShape = &shapes[createShape()];
                    }
                }
                break;
                
            case MODE_EDIT:
                if ( shapes.size() > 0 ){
                    for ( auto & it : shapes ){
                        if ( it.second.mousePressed(e) ) break;
                    }
                }
                break;
            
                
            case MODE_EDIT_DEL:
                if ( shapes.size() > 0 ){
                    for ( auto & it : shapes ){
                        if ( it.second.mousePressed(e, true) ) break;
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
                break;
                
            case MODE_EDIT:
                if ( shapes.size() > 0 ){
                    for ( auto & it : shapes ){
                        it.second.mouseDragged(e);
                    }
                }
                break;
                
            case MODE_RENDER:
                break;
        }
        // toolbar stuff
        if ( currentMode >= MODE_ADD ){
            toolBar.mouseDragged(e);
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
                        it.second.mouseReleased(e);
                    }
                }
                break;
                
            case MODE_RENDER:
                break;
        }
        
        // toolbar stuff
        if ( currentMode >= MODE_ADD ){
            toolBar.mouseReleased(e);
        }
    }
    
    //--------------------------------------------------------------
    void Manager::mouseMoved( ofMouseEventArgs & e ){
        switch (currentMode) {
            case MODE_WELCOME:
                break;
            case MODE_ADD:
                break;
                
            case MODE_EDIT:
                if ( shapes.size() > 0 ){
                    for ( auto & it : shapes ){
                        it.second.mouseMoved(e);
                    }
                }
                break;
                
            case MODE_RENDER:
                break;
        }
        
        // toolbar stuff
        if ( currentMode >= MODE_ADD ){
            toolBar.mouseMoved(e);
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
        
    }
    
    //--------------------------------------------------------------
    void Manager::onReload(){
        
    }
    
    //--------------------------------------------------------------
    void Manager::onMode(){
        Mode newMode = (Mode)(currentMode + 1);
        if ( newMode > MODE_EDIT ){
            newMode = MODE_RENDER;
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
                if ( currentShape != NULL ){
                    currentShape->close();
                    currentShape = NULL;
                }
                [MSA::ofxCocoa::glWindow() setIgnoresMouseEvents:NO];
                [MSA::ofxCocoa::glView() addCursorRect:MSA::ofxCocoa::rectForAllScreens() cursor:cursorEditA];
                [cursorEditA set];
                break;
            case MODE_ADD:
                [MSA::ofxCocoa::glWindow() setIgnoresMouseEvents:NO];
                [MSA::ofxCocoa::glView() addCursorRect:MSA::ofxCocoa::rectForAllScreens() cursor:cursorAdd];
                [cursorAdd set];
                break;
                
            case MODE_RENDER:
                currentShape = NULL;
                [MSA::ofxCocoa::glWindow() setIgnoresMouseEvents:YES];
                
                [MSA::ofxCocoa::glView() addCursorRect:MSA::ofxCocoa::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                break;
        }
        
        // set cursor
        switch (currentMode) {
            case MODE_WELCOME:
                [MSA::ofxCocoa::glView() addCursorRect:MSA::ofxCocoa::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                break;
            case MODE_EDIT:
                [MSA::ofxCocoa::glView() addCursorRect:MSA::ofxCocoa::rectForAllScreens() cursor:cursorEditA];
                [cursorEditA set];
                break;
                
            case MODE_EDIT_DEL:
                [MSA::ofxCocoa::glView() addCursorRect:MSA::ofxCocoa::rectForAllScreens() cursor:cursorEditD];
                [cursorEditD set];
                break;
                
            case MODE_ADD:
                [MSA::ofxCocoa::glView() addCursorRect:MSA::ofxCocoa::rectForAllScreens() cursor:cursorAdd];
                [cursorAdd set];
                break;
                
            case MODE_RENDER:
                [MSA::ofxCocoa::glView() addCursorRect:MSA::ofxCocoa::rectForAllScreens() cursor:cursorStandard];
                [cursorStandard set];
                break;
        }
    }
}