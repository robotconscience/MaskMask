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
        path.setMode(ofPath::POLYLINES);
        path.setFillColor(SHAPE_COLOR);
        selected = NULL;
        bMouseDown = false;
        bShapeSelected = false;
        bChanged = false;
    }
    
    //--------------------------------------------------------------
    Shape::~Shape(){
    }
    
    //--------------------------------------------------------------
    void Shape::draw( mm::Mode drawMode ){
        if ( bChanged ){
            path.clear();
            path.setMode(ofPath::POLYLINES);
            
            int ind = 0;
            for ( auto & p : points ){
                if ( ind == 0 ){
                    path.lineTo(p);
                } else {
                    if ( p.bUseBezier ){
                        path.bezierTo(p.bezierA, p.bezierB, p);
                    } else {
                        path.lineTo(p);
                    }
                }
                ind++;
            }
            if ( points.size() != 0 ){
                auto & p = points[0];
                if ( p.bUseBezier ){
                    path.bezierTo(p.bezierA, p.bezierB, p);
                } else {
//                    path.lineTo(p);
                }
                path.close();
            }
            bChanged  = false;
        }
        ofPushMatrix();
        path.draw();
        
        if ( drawMode == MODE_EDIT_SHAPE || drawMode == MODE_EDIT ){
            if ( bShapeSelected ){
                path.setFillColor(SHAPE_COLOR_SELECTED);
            } else {
                path.setFillColor(SHAPE_COLOR);
            }
            
            ofPushStyle();
            bool bFlip = true;
            for (auto & v : points ){
                ofSetColor(bFlip ? SHAPE_SQUARE_COLOR_A : SHAPE_SQUARE_COLOR_B );
                ofRect(v, SHAPE_SQUARE_SIZE, SHAPE_SQUARE_SIZE);
                if ( v.bUseBezier ){
                    ofSetColor(bFlip ? SHAPE_BEZIER_COLOR_A : SHAPE_BEZIER_COLOR_B);
                    ofRect(v.bezierA, SHAPE_BEZIER_SIZE, SHAPE_BEZIER_SIZE);
                    ofRect(v.bezierB, SHAPE_BEZIER_SIZE, SHAPE_BEZIER_SIZE);
                }
                bFlip = !bFlip;
            }
            ofPopStyle();
            if ( selected != NULL ){
                ofRect(*selected, SHAPE_SQUARE_SIZE_SELECTED, SHAPE_SQUARE_SIZE_SELECTED);
            }
        }
        
        ofPopMatrix();
    }
    
    //--------------------------------------------------------------
    void Shape::addVertex(ofVec2f & p ){
        points.push_back(Point());
        points.back().set(p);
        points.back().bezierA.set(p);
        points.back().bezierB.set(p);
        bChanged = true;
    }
    
    //--------------------------------------------------------------
    void Shape::deleteSelected(){
        if ( selected != NULL ){
            for ( int i=0; i<points.size(); i++){
                if ( points[i] == *selected){
                    points.erase(points.begin() + i );
                    selected = NULL;
                    bChanged = true;
                    break;
                }
            }
        }
    }
    
    //--------------------------------------------------------------
    void Shape::close(){
        path.close();
    }
    
    //--------------------------------------------------------------
    bool Shape::mousePressed( ofMouseEventArgs & e ){
        bool bFound = false;
        for ( auto & v : points ){
            if ( v.distance(e) < SHAPE_SQUARE_SIZE ){
                selected = &v;
                if ( ofGetKeyPressed( MM_KEY_BEZIER )){
                    v.bUseBezier = !v.bUseBezier;
                    bChanged = true;
                }
                bFound = true;
            } else if ( v.bezierA.distance(e) < SHAPE_SQUARE_SIZE ){
                selected = &v.bezierA;
                bFound = true;
            } else if ( v.bezierB.distance(e) < SHAPE_SQUARE_SIZE ){
                selected = &v.bezierB;
                bFound = true;
            }
        }
        if ( !bFound ){
            selected = NULL;
            if ( path.getOutline().size() > 0 ){
                if ( path.getOutline()[0].inside(e.x,e.y) ){
                    bShapeSelected = true;
                    pointPressed.set(e.x,e.y);
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
            bChanged = true;
        } else if ( bShapeSelected ){
            for ( auto & p : points ){
                p += (e-pointPressed);
                p.bezierA += (e-pointPressed);
                p.bezierB += (e-pointPressed);
            }
            bChanged = true;
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
        for ( auto & v : points ){
            if ( v.distance(e) < SHAPE_SQUARE_SIZE ){
                selected = &v;
                bFound = true;
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