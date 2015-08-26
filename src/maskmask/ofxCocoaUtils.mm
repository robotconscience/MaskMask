//
//  ofxCocoaUtils.cpp
//  MaskMask
//
//  Created by Brett Renfer on 7/30/15.
//
//

#include "ofxCocoaUtils.h"

namespace rc {
    
    NSScreen *screen(int screenIndex) {
        return [[NSScreen screens] objectAtIndex:screenIndex];
    }
    
    NSScreen *currentScreen( NSWindow * window ) {
        return [window screen];
    }
    
    NSScreen *mainScreen() {
        return [NSScreen mainScreen];
    }
    
    
    NSRect rectForScreen(int screenIndex) {
        return [screen(screenIndex) frame];
    }
    
    NSRect rectForCurrentScreen( NSWindow * window) {
        return [currentScreen(window) frame];
    }
    
    NSRect rectForMainScreen() {
        return [mainScreen() frame];
    }
    
    NSRect rectForAllScreens() {
        NSRect rect = NSZeroRect;
        for(NSScreen *s in [NSScreen screens]) rect = NSUnionRect(rect, [s frame]);
        return rect;
    }
    
    void setWindowPosition( NSWindow * window, NSView * view, const ofPoint & p ){
        NSRect viewFrame  = [ view frame ];
        NSRect screenRect = [ [window screen ] frame ];
        
        NSPoint position = NSMakePoint( p.x, screenRect.size.height - viewFrame.size.height - p.y );
        [window setFrameOrigin: position ];
    }
}