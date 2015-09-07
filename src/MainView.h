#pragma once

#include "ofMain.h"
#include "ofxCocoaGLView.h"

#include "MaskMask.h"

@interface MainView : ofxCocoaGLView {
    mm::Manager * manager;
    id delegate;
}

- (void)setup;
- (void)update;
- (void)draw;
- (void)exit;

- (void)keyPressed:(int)key;
- (void)keyReleased:(int)key;
- (void)mouseMoved:(NSPoint)p;
- (void)mouseDragged:(NSPoint)p button:(int)button;
- (void)mousePressed:(NSPoint)p button:(int)button;
- (void)mouseReleased:(NSPoint)p button:(int)button;
- (void)windowResized:(NSSize)size;

- (void) changeMode:(int) whichMode;
- (void) newColor:(NSColor *) color;

- (void) save;
- (void) saveAs;
- (void) load;
- (void) reload;

- (void) setAppDelegate:(id) delegate;

@end
