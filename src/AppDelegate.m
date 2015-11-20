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
    [mainView setTextField:helper];
    
    //
    
    int nscreens = [[NSScreen screens] count];
    if ( nscreens <= 1 ){
        [screenSlider setEnabled:NO];
    }
}


-(void)changeMode:(id)sender
{
    int mode = [[sender selectedCell] tag];
    [mainView changeModeTo:mode];
}

-(void)changeColor:(id)sender
{
    NSColor * color = [sender color];
    [mainView newColor:color];
}

-(void)changeScreen:(id)sender
{
    [mainView setWhichScreen:[sender integerValue]];
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


-(IBAction) import:(id) sender;
{
    [mainView import];
}


-(void) showTools
{
    [[toolsView window] makeKeyAndOrderFront:nil];
    [[mainView window] makeKeyAndOrderFront:nil];
    
}
-(void) hideTools
{
    [[toolsView window] orderOut:self];
    
}

@end
