//
//  MaskMask.h
//  MaskMask
//
//  Created by Brett Renfer on 5/14/15.
//
//

#pragma once

#include "ofMain.h"
#import "MMConstants.h"
#import "StatusbarDelegate.h"

namespace mm {
    
    class Point : public ofVec3f {
    public:
        Point(){ bUseBezier = false; };
        ofVec3f bezierA, bezierB;
        bool bUseBezier;
    };
    
    class Shape {
    public:
        Shape();
        ~Shape();
        void draw( mm::Mode drawMode );
        void addVertex(ofVec2f & p );
        void deleteSelected();
        void close();
        
        bool mousePressed( ofMouseEventArgs & e, bool bDelete = false );
        void mouseDragged( ofMouseEventArgs & e );
        void mouseReleased( ofMouseEventArgs & e );
        void mouseMoved( ofMouseEventArgs & e );
        
        bool shouldDelete();
        
    protected:
        ofVec3f * selected;
        ofVec2f pointPressed, originalCenter; // where shape was clicked
        bool bMouseDown, bShapeSelected;
        
        vector<Point> points;
        
        ofPath path;
        bool bChanged, bKillMe;
    };
    
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
        
        StatusBar statusMenu;
        
        // properties
        ofShader    renderShader;
        ofFbo       renderFbo;
        Mode        currentMode;
        
        // shapes
        std::map<int, Shape> shapes;
        Shape * currentShape;
        
        // switches
        bool bNeedToResize; // set when window resizes
        bool bAddCursor;    // in edit mode, show 'add' or 'subtract'
        
        // important stuff
        ofMutex mux;
    };
}
