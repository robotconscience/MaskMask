#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[picker colorPanel] setLevel:NSMainMenuWindowLevel+1];
    [mainView setAppDelegate:self];
    [mainView setModeRadio:modeRadio];
}


-(void)changeMode:(id)sender
{
    [mainView changeMode:[[sender selectedCell] tag]];
}

-(void)changeColor:(id)sender
{
    NSColor * color = [sender color];
    [mainView newColor:color];
}


-(IBAction)openPanel:(id)sender
{
}

-(IBAction) save:(id) sender
{
    [mainView save];
}
-(IBAction) saveAs:(id) sender
{
    [mainView saveAs];
}
-(IBAction) load:(id) sender;
{
    [mainView load];
}

-(IBAction) reload:(id) sender;
{
    [mainView reload];
}


-(void) showTools
{
    [[toolsView window] makeKeyAndOrderFront:nil];
}
-(void) hideTools
{
    [[toolsView window] orderOut:self];
    
}

@end
