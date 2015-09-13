#import "ToolsView.h"

@implementation ToolsView

- (void)setup
{
    NSWindow * cocoaWindow = [self window];
    [cocoaWindow setLevel:NSMainMenuWindowLevel + 1];
    [self setTranslucent:YES];
    [self enableMouseEvents:NO];
    [self enableWindowEvents:NO];
}

- (void)update
{
}

- (void)draw
{
    ofBackground(ofColor(0,0));
}

- (void)exit
{
	
}

- (void)keyPressed:(int)key
{
}

- (void)keyReleased:(int)key
{
	
}

- (void)mouseMoved:(NSPoint)p
{
	
}

- (void)mouseDragged:(NSPoint)p button:(int)button
{
	
}

- (void)mousePressed:(NSPoint)p button:(int)button
{
	
}

- (void)mouseReleased:(NSPoint)p button:(int)button
{
	
}

- (void)windowResized:(NSSize)size
{
	
}

- (void) changeMode:(int) whichMode
{
//    mainWindow->manager->setMode(whichMode);
}

@end