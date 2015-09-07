#import <Cocoa/Cocoa.h>
#import "ofxCocoaGLView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow *window;
    IBOutlet ofxCocoaGLView* mainView;
    IBOutlet ofxCocoaGLView* toolsView;
    IBOutlet NSColorWell * picker;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)changeMode:(id)sender;
-(IBAction)changeColor:(id)sender;
-(IBAction)openPanel:(id)sender;

// save / load
-(IBAction) save:(id) sender;
-(IBAction) saveAs:(id) sender;
-(IBAction) load:(id) sender;
-(IBAction) reload:(id) sender;

-(void) showTools;
-(void) hideTools;

@end
