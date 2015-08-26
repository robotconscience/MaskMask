//
//  ofxCocoaUtils.h
//  MaskMask
//
//  Created by Brett Renfer on 7/30/15.
//
//

#pragma once

#include "ofxCocoaWindow.h"

// most of these are from Memo Atken's (memo.tv) ofxCocoa addon

namespace rc {
    ofxCocoaWindow * cocoaWindow();
    GLView * glView();
    NSWindow * glWindow();
    NSScreen *screen(int screenIndex);
    NSScreen *currentScreen();
    NSScreen *mainScreen();
    NSRect rectForScreen(int screenIndex);
    NSRect rectForCurrentScreen();
    NSRect rectForMainScreen();
    NSRect rectForAllScreens();
    void   setWindowLevel( NSInteger newLevel );
}