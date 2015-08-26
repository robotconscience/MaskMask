#import "ToolsView.h"

@implementation ToolsView

- (void)setup
{
    NSWindow * cocoaWindow = [self window];
    [cocoaWindow setLevel:NSMainMenuWindowLevel + 1];
}

- (void)update
{
}

- (void)draw
{
	ofBackground(0, 255, 0);
	
	ofNoFill();
	ofSetColor(255);
	ofCircle(self.mouseX, self.mouseY, 100);
	
	string str = "View2: " + ofToString(self.mouseX) +  " " + ofToString(self.mouseY);
	ofDrawBitmapString(str, 10, 20);
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

@end