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
    
    // this is a hack to make the color panel float on top!
    
    if([NSColorPanel sharedColorPanelExists] && [[NSColorPanel sharedColorPanel] isVisible]){
        [[NSColorPanel sharedColorPanel] setLevel:NSMainMenuWindowLevel + 2];
    }
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

//--------------------------------------------------------------
- (void) changeMode:(int) whichMode
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

@end