#include "ofMain.h"
#include "ofApp.h"

#include "ofxCocoa.h"
#include <Cocoa/Cocoa.h>

//========================================================================
int main()
{
    
    // SETUP COCOA WINDOW
    MSA::ofxCocoa::InitSettings			initSettings;
    initSettings.isOpaque				= false;
    initSettings.windowLevel			= NSScreenSaverWindowLevel;
    initSettings.hasWindowShadow		= false;
    initSettings.numFSAASamples			= 4;
    initSettings.windowMode				= OF_WINDOW;
    initSettings.windowStyle			= NSBorderlessWindowMask;
    initSettings.initRect				= MSA::ofxCocoa::rectForAllScreens();
    initSettings.initRect.size.height   -= 50;
    
    MSA::ofxCocoa::AppWindow cocoaWindow(initSettings);
    ofSetupOpenGL(&cocoaWindow, 0, 0, 0);		// all other parameters are ignored, use initSettings above
    
    // START TEST APP
    
    ofRunApp( new ofApp() );
}
