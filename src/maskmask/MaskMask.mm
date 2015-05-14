//
//  MaskMask.cpp
//  MaskMask
//
//  Created by Brett Renfer on 5/14/15.
//
//

#include "MaskMask.h"
#include "ofxCocoa.h"

namespace mm {
    
#pragma mark Shape
    
    //--------------------------------------------------------------
    Shape::Shape(){
        setMode(ofPath::POLYLINES);
        setFillColor(SHAPE_COLOR);
        selected = NULL;
        bMouseDown = false;
        bShapeSelected = false;
    }
    
    //--------------------------------------------------------------
    Shape::~Shape(){
    }
    
    //--------------------------------------------------------------
    void Shape::draw( mm::Mode drawMode ){
        tessellate();
        
        ofPushMatrix();
        ofTranslate(*this);
        ofPath::draw();
        
        if ( drawMode == MODE_EDIT_SHAPE || drawMode == MODE_EDIT ){
            if ( bShapeSelected ){
                setFillColor(SHAPE_COLOR_SELECTED);
            } else {
                setFillColor(SHAPE_COLOR);
            }
            for ( auto & path : getOutline() ){
                for (auto & v : path.getVertices() ){
                    ofRect(v, SHAPE_SQUARE_SIZE, SHAPE_SQUARE_SIZE);
                }
            }
            if ( selected != NULL ){
                ofRect(*selected, SHAPE_SQUARE_SIZE_SELECTED, SHAPE_SQUARE_SIZE_SELECTED);
            }
        }
        
        ofPopMatrix();
    }
    
    //--------------------------------------------------------------
    void Shape::addVertex(ofVec2f & p ){
        setMode(ofPath::POLYLINES);
        lineTo(p);
    }
    
    //--------------------------------------------------------------
    void Shape::deleteSelected(){
        if ( selected != NULL ){
            for ( auto & path : getOutline() ){
                auto & verts = path.getVertices();
                for ( int i=0; i<verts.size(); i++){
                    if ( verts[i] == *selected){
                        verts.erase(verts.begin() + i );
                        selected = NULL;
                        flagShapeChanged();
                        break;
                    }
                }
            }
        }
    }
    
    //--------------------------------------------------------------
    bool Shape::mousePressed( ofMouseEventArgs & e ){
        bool bFound = false;
        for ( auto & path : getOutline() ){
            for (auto & v : path.getVertices() ){
                if ( v.distance(e) < SHAPE_SQUARE_SIZE ){
                    selected = &v;
                    bFound = true;
                }
            }
        }
        if ( !bFound ){
            selected = NULL;
            if ( getOutline().size() > 0 ){
                if ( getOutline()[0].inside(e.x,e.y) ){
                    bShapeSelected = true;
                    pointPressed.set(e.x,e.y);
                    originalCenter = getOutline()[0].getCentroid2D();
                    bFound = true;
                } else {
                    bShapeSelected = false;
                }
            } else {
                bShapeSelected = false;
            }
        }
        bMouseDown = true;
        return bFound;
    }
    
    //--------------------------------------------------------------
    void Shape::mouseDragged( ofMouseEventArgs & e ){
        if ( selected != NULL && bMouseDown ){
            selected->set(e);
            flagShapeChanged();
        } else if ( bShapeSelected ){
            translate(e-pointPressed);
            pointPressed.set(e.x,e.y);
        }
    }
    
    //--------------------------------------------------------------
    void Shape::mouseReleased( ofMouseEventArgs & e ){
        selected = NULL;
        bMouseDown = false;
        bShapeSelected = false;
    }
    
    //--------------------------------------------------------------
    void Shape::mouseMoved( ofMouseEventArgs & e ){
        bool bFound = false;
        for ( auto & path : getOutline() ){
            for (auto & v : path.getVertices() ){
                if ( v.distance(e) < SHAPE_SQUARE_SIZE ){
                    selected = &v;
                    bFound = true;
                }
            }
        }
        if ( !bFound ) selected = NULL;
    }
    
#pragma mark Manager
    
    //--------------------------------------------------------------
    Manager::Manager(){
        currentMode = MODE_EDIT_SHAPE; // todo: should be tied to a "first time" setting
        bNeedToResize = false;
    }
    
    //--------------------------------------------------------------
    Manager::~Manager(){
        ofRemoveListener(statusMenu.onSave, this, &Manager::onSave);
        ofRemoveListener(statusMenu.onReload, this, &Manager::onReload);
        ofRemoveListener(statusMenu.onToggleMode, this, &Manager::onMode);
        
        // get this show on the road
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
        
        // load render shader
        renderShader.load("", ofToDataPath("shaders/render.frag"));
        renderFbo.allocate(ofGetWidth(), ofGetHeight());
        
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
            renderFbo.allocate(ofGetWidth(), ofGetHeight());
        }
    }
    
    //--------------------------------------------------------------
    void Manager::draw(ofEventArgs & e ){
        renderFbo.begin();
        ofClear(0);
        ofSetColor(255);
        switch( currentMode ){
            case MODE_EDIT_SHAPE:
                ofDrawBitmapString("EDIT SHAPE", 20,100);
                break;
            case MODE_RENDER:
                break;
            case MODE_EDIT:
                ofDrawBitmapString("EDIT", 20,100);
                break;
        }
        
//        cout << shapes.size() << endl;
        
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
                
            case MODE_EDIT_SHAPE:
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
        switch (currentMode) {
            case MODE_EDIT_SHAPE:
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
                
            case MODE_RENDER:
                break;
        }
    }
    
    //--------------------------------------------------------------
    void Manager::mouseDragged( ofMouseEventArgs & e ){
        switch (currentMode) {
            case MODE_EDIT_SHAPE:
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
    }
    
    //--------------------------------------------------------------
    void Manager::mouseReleased( ofMouseEventArgs & e ){
        switch (currentMode) {
            case MODE_EDIT_SHAPE:
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
    }
    
    //--------------------------------------------------------------
    void Manager::mouseMoved( ofMouseEventArgs & e ){
        switch (currentMode) {
            case MODE_EDIT_SHAPE:
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
    // Mode methods
    //--------------------------------------------------------------
    
    //--------------------------------------------------------------
    void Manager::setMode( Mode newMode ){
        currentMode = newMode;
        
        switch (newMode) {
            case MODE_EDIT:
                if ( currentShape != NULL ){
                    currentShape->close();
                    currentShape = NULL;
                }
                [MSA::ofxCocoa::glWindow() setIgnoresMouseEvents:NO];
                break;
            case MODE_EDIT_SHAPE:
                [MSA::ofxCocoa::glWindow() setIgnoresMouseEvents:NO];
                break;
                
            case MODE_RENDER:
                currentShape = NULL;
                [MSA::ofxCocoa::glWindow() setIgnoresMouseEvents:YES];
                break;
        }
    }
}