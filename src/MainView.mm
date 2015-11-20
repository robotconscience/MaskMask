#import "Poco/Format.h"
#import "MainView.h"
#import "AppDelegate.h"

@implementation MainView

//--------------------------------------------------------------
- (void)setup
{
    // this code is amazing, and from here:
    // https://github.com/hideyukisaito/ofxBundleResources
    
    CFURLRef  bundleURL_ = CFBundleCopyResourcesDirectoryURL(CFBundleGetMainBundle());
    char buf_[4096];
    
    if (CFURLGetFileSystemRepresentation(bundleURL_, TRUE, (UInt8 *)buf_, 4096))
    {
        string path_ = buf_;
        string str   = "";
        ofSetDataPathRoot(Poco::format("%s/%s", path_, str));
        path_.clear();
    }
    CFRelease(bundleURL_);
    
    manager = new mm::Manager();
    [self setTranslucent:YES];
    manager->setAndConfigureWindow( [self window], self );
    manager->setup();
    
    // setup helper
    helper.setup();
    
    ofBackground(ofColor(0,0));
}

//--------------------------------------------------------------
- (void)update
{
    manager->update();
    
    // this is a hack to make the color panel float on top!
    
    if([NSColorPanel sharedColorPanelExists] && [[NSColorPanel sharedColorPanel] isVisible]){
        [[NSColorPanel sharedColorPanel] setLevel:NSMainMenuWindowLevel + 2];
    }
    
    // another sort-of hack to decide if we need to show the toolz
    if ( manager->getShowTools() ){
        [delegate showTools];
    }
    [[self window] makeKeyAndOrderFront:nil];
}

//--------------------------------------------------------------
- (void)draw
{
    ofEnableSmoothing();
    glEnable(GL_MULTISAMPLE);
    manager->draw();
    glDisable(GL_MULTISAMPLE);
    ofDisableSmoothing();
}

//--------------------------------------------------------------
- (void)exit
{
	
}

//--------------------------------------------------------------
- (void)keyPressed:(int)key
{
}

//--------------------------------------------------------------
- (void)keyReleased:(int)key
{
	
}

//--------------------------------------------------------------
- (void)mouseMoved:(NSPoint)p
{
}

//--------------------------------------------------------------
- (void)mouseDragged:(NSPoint)p button:(int)button
{
	
}

//--------------------------------------------------------------
- (void)mousePressed:(NSPoint)p button:(int)button
{
}

//--------------------------------------------------------------
- (void)mouseReleased:(NSPoint)p button:(int)button
{
	
}

//--------------------------------------------------------------
- (void)windowResized:(NSSize)size
{
    if ( manager ){
        mm::Settings & inst = mm::Settings::get();
        [self setWhichScreen:inst.whichScreen];
    }
}

#pragma mark Interface Actions

//--------------------------------------------------------------
- (void) changeModeTo:(int) whichMode
{
    manager->setMode( (mm::Mode) whichMode);
}


//--------------------------------------------------------------
- (void) newColor:(NSColor *) color
{
    ofFloatColor newColor;
    newColor.set( color.redComponent, color.greenComponent, color.blueComponent);
    
    ofColor colorOut;
    colorOut.set(newColor.r * 255., newColor.g * 255., newColor.b * 255);
    
    manager->setDebugColor(colorOut);
}

//--------------------------------------------------------------
- (void) save
{
    manager->save();
}

//--------------------------------------------------------------
- (void) saveAs
{
    ofFileDialogResult r = ofSystemSaveDialog("mask_settings.xml", "Save mask");
    if ( r.bSuccess ){
        manager->saveAs(r.getPath());
    }
}

//--------------------------------------------------------------
- (void) load
{
    ofFileDialogResult r = ofSystemLoadDialog("Load mask", false, "../../" );
    if ( r.bSuccess ){
        manager->load(r.getPath());
    }
}
//--------------------------------------------------------------
- (void) reload
{
    manager->reload();
}

//--------------------------------------------------------------
- (void) import
{
    ofFileDialogResult r = ofSystemLoadDialog("Load SVG", false, "../../" );
    if ( r.bSuccess ){
        manager->import(r.getPath());
    }
}

//--------------------------------------------------------------
- (void) setAppDelegate:(id) d
{
    delegate = d;
    
    if ( mm::Settings::get().bDidWelcome ){
        [delegate showTools];
    }
}


//--------------------------------------------------------------
- (void) setModeRadio:(id) radio
{
    modeRadio = radio;
}

//--------------------------------------------------------------
- (void) setTextField: (id) textField
{
    hTextField = textField;
}

//--------------------------------------------------------------
- (void) onChangeMode:(mm::Mode) newMode
{
    [modeRadio selectCellWithTag:(int) newMode];
    NSString * str = [[NSString alloc] initWithUTF8String:helper.getEntry(newMode).c_str()];
    [hTextField setStringValue:str];
}

//--------------------------------------------------------------
- (BOOL) canBecomeKeyView
{
    return YES;
}

//--------------------------------------------------------------
- (void) setWhichScreen: (int) whichScreen
{
    mm::Settings::get().whichScreen = whichScreen;
    NSRect rect = rc::rectForScreen(whichScreen);
    [[self window] setFrame:rect display:YES ];
    manager->resize( rect.size.width, rect.size.height );
}


@end