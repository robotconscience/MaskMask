//
//  ToolBar.h
//  MaskMask
//
//  Created by Brett Renfer on 5/19/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#pragma once

#include "ofMain.h"
#include "MMConstants.h"

namespace mm {

    class Tool : public ofRectangle {
    public:
        void load( string image_path );
        void draw();
        
        Mode myMode;
        
    protected:
        
        ofImage toolImage;
    };
    
    class ToolBar : public ofRectangle
    {
    public:
    
        void setup();
        void draw();
        
        bool mousePressed( ofMouseEventArgs & e );
        void mouseDragged( ofMouseEventArgs & e );
        void mouseReleased( ofMouseEventArgs & e );
        void mouseMoved( ofMouseEventArgs & e );
        void windowResized( ofResizeEventArgs & e );
        
        vector<Tool> tools;
        
        ofEvent<Mode> onChangeTool;
        
    protected:
        bool bDragging;
        ofVec2f dragPoint;
    };
}
