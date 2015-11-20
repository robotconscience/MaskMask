#pragma once

#include "ofMain.h"
#include "ofxCocoaGLView.h"

#include "MaskMask.h"

@interface MainView : ofxCocoaGLView {
    mm::Manager *   manager;
    mm::Helper          helper;
    id delegate;
    id modeRadio;
    id hTextField;
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

- (void) changeModeTo:(int) whichMode;
- (void) newColor:(NSColor *) color;

- (void) save;
- (void) saveAs;
- (void) load;
- (void) reload;
- (void) import;

- (void) setAppDelegate:(id) delegate;
- (void) setModeRadio:(id) radio;
- (void) setTextField: (id) textField;

- (void) onChangeMode:(mm::Mode) newMode;

// set which screen active
- (void) setWhichScreen: (int) whichScreen;

@end
