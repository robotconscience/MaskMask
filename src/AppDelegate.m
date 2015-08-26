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

@end
