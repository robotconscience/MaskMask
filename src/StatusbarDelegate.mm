//
//  StatusbarDelegate.m
//  MaskMask
//
//  Created by Brett Renfer on 4/30/15.
//
//

#import "StatusbarDelegate.h"

@interface StatusbarDelegate ()

@property (readwrite) StatusBar * ofObjectRef;

@end

@implementation StatusbarDelegate
@synthesize StatusMenu = _StatusMenu;
@synthesize reload = _reload;
@synthesize save = _save;
@synthesize quit = _quit;
@synthesize toggleMode = _toggleMode;
@synthesize statusBar = _statusBar;

@synthesize ofObjectRef;


- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
    return YES;
}

- (void) reloadAction: (id)sender
{
    
    if ( self.ofObjectRef != NULL ) self.ofObjectRef->reload();
}

- (void) saveAction: (id)sender
{
    
    if ( self.ofObjectRef != NULL ) self.ofObjectRef->save();
}

- (void) toggleAction: (id)sender
{
    if ( self.ofObjectRef != NULL ) self.ofObjectRef->toggleMode();
}


-(void)setup:(StatusBar*) ofRef{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.ofObjectRef = ofRef;
    
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage * barImage = [NSImage imageNamed:@"icon_task_white.png"];
    
    //TODO
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    
    self.statusBar.image = barImage;
    
    self.StatusMenu = [NSMenu new];
    
    // add items
    self.toggleMode = [self.StatusMenu addItemWithTitle:@"Toggle Mode" action:@selector(toggleAction:) keyEquivalent:@"M"];
    self.reload = [self.StatusMenu addItemWithTitle:@"Reload" action:@selector(reloadAction:) keyEquivalent:@"R"];
    self.save = [self.StatusMenu addItemWithTitle:@"Save" action:@selector(saveAction:) keyEquivalent:@""];
    self.quit = [self.StatusMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    
    // this is a product of me not knowing objective c?
    [self.toggleMode setTarget:self];
    [self.reload setTarget:self];
    [self.save setTarget:self];
    
    self.statusBar.menu = self.StatusMenu;
    self.statusBar.highlightMode = YES;
    
    [pool drain];
}

//
//
//    // you can also set an image
//    NSImage * barImage = [NSImage imageNamed:@"icon_task_white.png"];
//    self.statusBar.image = barImage;
//    
//    self.statusBar.menu = self.StatusMenu;
//    self.statusBar.highlightMode = YES;
//}

@end

#pragma mark Statusbar

void StatusBar::setup(){
    delegate = [StatusbarDelegate new];
    [delegate setup:this];
}

void StatusBar::toggleMode(){
    ofNotifyEvent(onToggleMode, this);
}

void StatusBar::save(){
    ofNotifyEvent(onSave, this);
}

void StatusBar::reload(){
    ofNotifyEvent(onReload, this);
}
