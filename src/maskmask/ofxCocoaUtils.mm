//
//  ofxCocoaUtils.cpp
//  MaskMask
//
//  Created by Brett Renfer on 7/30/15.
//
//

#include "ofxCocoaUtils.h"

namespace rc {
    
    ofxCocoaWindow * cocoaWindow(){
        static ofxCocoaWindow * windowInstance = NULL;
        if ( windowInstance == NULL){
            windowInstance = static_cast<ofxCocoaWindow *>(ofGetWindowPtr());
        }
        return windowInstance;
    }
    
    GLView * glView(){
        return cocoaWindow()->getGlView();
        
    }
    
    NSWindow * glWindow(){
        return cocoaWindow()->getNSWindow();
    }
    
    NSScreen *screen(int screenIndex) {
        return [[NSScreen screens] objectAtIndex:screenIndex];
    }
    
    NSScreen *currentScreen() {
        return [glWindow() screen];
    }
    
    NSScreen *mainScreen() {
        return [NSScreen mainScreen];
    }
    
    
    NSRect rectForScreen(int screenIndex) {
        return [screen(screenIndex) frame];
    }
    
    NSRect rectForCurrentScreen() {
        return [currentScreen() frame];
    }
    
    NSRect rectForMainScreen() {
        return [mainScreen() frame];
    }
    
    NSRect rectForAllScreens() {
        NSRect rect = NSZeroRect;
        for(NSScreen *s in [NSScreen screens]) rect = NSUnionRect(rect, [s frame]);
        return rect;
    }
    
    
    void setWindowLevel( NSInteger newLevel ){
        [glWindow() setLevel:newLevel];
    }
}