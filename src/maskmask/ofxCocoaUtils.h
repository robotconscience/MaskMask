//
//  ofxCocoaUtils.h
//  MaskMask
//
//  Created by Brett Renfer on 7/30/15.
//
//

#pragma once

#include "ofMain.h"
#include "ofxCocoaGLView.h"

// most of these are from Memo Atken's (memo.tv) ofxCocoa addon

namespace rc {
    NSScreen *screen(int screenIndex);
    NSScreen *mainScreen( NSWindow * window );
    NSRect rectForScreen(int screenIndex);
    NSRect rectForCurrentScreen();
    NSRect rectForMainScreen( NSWindow * window );
    NSRect rectForAllScreens();
    
    void setWindowPosition( NSWindow * window, NSView * view, const ofPoint & position );
    
    static ofPoint ofPointFromOutsideEvent(NSView * view, NSEvent* theEvent) {
        NSPoint p = [view convertPoint:[theEvent locationInWindow] fromView:nil];
        return ofPoint(p.x, p.y, 0);
    }
}