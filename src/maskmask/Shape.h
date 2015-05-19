//
//  Shape.h
//  MaskMask
//
//  Created by Brett Renfer on 5/19/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#pragma once

#include "ofMain.h"
#include "MMConstants.h"

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
}