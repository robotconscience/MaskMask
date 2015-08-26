//
//  MaskMask.h
//  MaskMask
//
//  Created by Brett Renfer on 5/14/15.
//
//

#pragma once

#include "ofMain.h"
#include "MMConstants.h"
#include "Shape.h"
#include "ToolBar.h"
#include "StatusbarDelegate.h"
#include "ofxCocoaUtils.h"

namespace mm {
    
    class Manager {
    public:
        
        Manager();
        ~Manager();
        void setup();
        
        void setMode( Mode newMode );
        
        // shape methods
        int     createShape();
        void    removeShape( int shapeId );
        Shape & getShape( int shapeId );
        
    protected:
        void update( ofEventArgs & e );
        void draw( ofEventArgs & e );
        void keyPressed( ofKeyEventArgs & e );
        void mousePressed( ofMouseEventArgs & e );
        void mouseDragged( ofMouseEventArgs & e );
        void mouseReleased( ofMouseEventArgs & e );
        void mouseMoved( ofMouseEventArgs & e );
        void windowResized( ofResizeEventArgs & e );
        
        // menu events
        void onSave();
        void onReload();
        void onMode();
        void onChangeMode( Mode & m );
        
        StatusBar statusMenu;
        
        // properties
        ofShader    renderShader;
        ofFbo       renderFbo;
        Mode        currentMode;
        
        // shapes
        std::map<int, Shape *> shapes;
        Shape * currentShape;
        
        // toolz
//        ToolBar toolBar;
        
        // switches
        bool bNeedToResize; // set when window resizes
        bool bAddCursor;    // in edit mode, show 'add' or 'subtract'
        
        // workaround: queues to fix funky threading with mouse
        vector<ofVec2f> pointQueue;
        mutex mux;
    };
}
