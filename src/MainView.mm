#import "MainView.h"

@implementation MainView

//--------------------------------------------------------------
- (void)setup
{
    ofSetDataPathRoot("../Resources/");
    manager = new mm::Manager();
    [self setTranslucent:YES];
    manager->setAndConfigureWindow( [self window], self );
    manager->setup();
    
    ofBackground(ofColor(0,0));
}

//--------------------------------------------------------------
- (void)update
{
    manager->update();
    
}

//--------------------------------------------------------------
- (void)draw
{
    manager->draw();
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
	
}

@end