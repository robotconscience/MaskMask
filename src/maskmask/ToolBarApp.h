//
//  ToolBarApp.h
//  MaskMask
//
//  Created by Brett Renfer on 8/20/15.
//
//

#include "ofMain.h"
#include "ToolBar.h"

class ToolBarApp : public ofBaseApp {
public:
    
    void setup();
    void update();
    void draw();
    
    // toolz
    mm::ToolBar toolBar;

};
