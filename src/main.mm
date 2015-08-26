#include "ofMain.h"
#include "ofApp.h"

#include "ofxCocoaWindow.h"
#include "ofxCocoaUtils.h"

#include "ofAppGLFWWindow.h"

//========================================================================
int main()
{
    
    // SETUP COCOA WINDOW
    NSRect r = rc::rectForAllScreens();
    
    ofxCocoaWindowSettings settings;
    settings.width = r.size.width;
    settings.height = r.size.height;
    settings.setPosition(ofVec2f(0,0));
    settings.isOpaque = false;
    settings.hasWindowShadow = false;
    settings.windowLevel = NSMainMenuWindowLevel;
    settings.styleMask = NSBorderlessWindowMask;
    
    ofInit();
    shared_ptr<ofxCocoaWindow> mainWindow = shared_ptr<ofxCocoaWindow>( new ofxCocoaWindow());
    mainWindow.get()->setup(settings);
    ofGetMainLoop()->addWindow(mainWindow);
    
    shared_ptr<ofApp> mainApp(new ofApp);
//    mainApp.get()->manager.toolBar.setup();
    
//    ofAddListener(guiWindow->events().draw, &mainApp.get()->manager.toolBar, &mm::ToolBar::draw);
    ofRunApp(mainWindow, mainApp);
    ofRunMainLoop();
}
