//
//  StatusbarDelegate.h
//  MaskMask
//
//  Created by Brett Renfer on 4/30/15.
//
//

#import "ofMain.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

class StatusBar;

@interface StatusbarDelegate : NSObject {
    NSStatusItem * _statusBar;
    NSMenu *_StatusMenu;
    NSMenuItem *_reload;
    NSMenuItem *_save;
    NSMenuItem *_quit;
    NSMenuItem *_toggleMode;
    
    // for sending through events and stuff
    StatusBar * ofObjectRef;
}

@property (nonatomic, retain) NSMenu *StatusMenu;
@property (nonatomic, retain) NSMenuItem *reload;
@property (nonatomic, retain) NSMenuItem *import;
@property (nonatomic, retain) NSMenuItem *save;
@property (nonatomic, retain) NSMenuItem *quit;
@property (nonatomic, retain) NSMenuItem *toggleMode;

@property (strong, nonatomic) NSStatusItem *statusBar;

- (void) reloadAction: (id)sender;
- (void) saveAction: (id)sender;
- (void) importAction: (id)sender;
- (void) toggleAction: (id)sender;
- (BOOL) validateMenuItem:(NSMenuItem *)menuItem;
//- (void) quitAction: (id)sender;

@end


class StatusBar {
public:
    
    void setup();
    
    ofEvent<void> onReload, onSave, onToggleMode, onImport;
    
    void toggleMode();
    void save();
    void reload();
    void import();
    
private:
    
    StatusbarDelegate * delegate;
};