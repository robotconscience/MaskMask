//
//  MMConstants.h
//  MaskMask
//
//  Created by Brett Renfer on 5/14/15.
//
//

#pragma once

#include <Cocoa/Cocoa.h>
#include <QuartzCore/QuartzCore.h>
#include "ofxCocoaUtils.h"

namespace mm {
    static const int SHAPE_SQUARE_SIZE = 10;
    static const int SHAPE_SQUARE_SIZE_SELECTED = 12;
    static const int SHAPE_BEZIER_SIZE = 5;
    
    static const ofColor SHAPE_SQUARE_COLOR_A(0,255,0);
    static const ofColor SHAPE_SQUARE_COLOR_B(0,0,255);
    static const ofColor SHAPE_BEZIER_COLOR_A(255,0,255);
    static const ofColor SHAPE_BEZIER_COLOR_B(0,255,255);
    
    static ofColor SHAPE_COLOR(255,0,0);
    static const ofColor SHAPE_COLOR_SELECTED(255,255,0,150);
    
    #define MM_KEY_BEZIER OF_KEY_ALT
    
    static const float MM_RENDER_ALPHA = 1.;
    static const float MM_RENDER_PREVIEW_ALPHA = .75;
    
    static const int MM_TUTORIAL_TOOLSLIDE = 2;
    
    // App Mode
    enum Mode {
        MODE_WELCOME = 0,
        MODE_RENDER_PREVIEW,
        MODE_RENDER,
        MODE_ADD,
        MODE_EDIT_DEL,
        MODE_EDIT,
    };
    
    static string getModeAsString( Mode mode ){
        switch( mode ){
            case MODE_WELCOME:
                return "Welcome";
            case MODE_RENDER:
                return "Render";
            case MODE_ADD:
                return "Add";
            case MODE_EDIT_DEL:
                return "Delete";
            case MODE_EDIT:
                return "Edit";
            default:
                return "";
        }
    }
    
    // phontz
    class FontManager {
    public:
        static FontManager & get(){
            static FontManager me;
            if ( !me.fontBold.isLoaded()){
//                me.fontBold.load( ofToDataPath(TOOLBAR_FONT_BOLD), TOOLBAR_FONT_SIZE );
            }
            
            if ( !me.font.isLoaded()){
//                me.font.load( ofToDataPath(TOOLBAR_FONT), TOOLBAR_FONT_SIZE );
            }
            return me;
        }
        
        ofTrueTypeFont font, fontBold;

    protected:
        
        FontManager(){
            
        }
    };
    
    // settings
    class Settings {
    public:
        
        static Settings& get()
        {
            static Settings inst; // Guaranteed to be destroyed.
            static bool bInstance = false;
            
            if ( !bInstance ){
                // these should be inside 'Resources'
                ofXml settings;
                if (settings.load(ofToDataPath( "settings.xml" ))){
                    settings.setTo("settings");
                    inst.settingsFile = settings.getValue("settingsFile");
                    settings.setTo("welcome");
                    inst.bDidWelcome = settings.getBoolValue("didWelcome");
                    inst.welcomeMillis = settings.getIntValue("timing");
                    settings.setToParent();
                }
                
                bInstance = true;
            }
            
            return inst;
        }
        
        static void save()
        {
            auto & inst = get();
            ofXml settings;
            settings.addChild("settings");
            settings.setTo("settings");
            settings.addValue("settingsFile", inst.settingsFile);
            settings.addChild("welcome");
            settings.setTo("welcome");
            settings.addValue("didWelcome", inst.bDidWelcome);
            settings.addValue("timing", inst.welcomeMillis);
            settings.setToParent();
            settings.save(ofToDataPath( "settings.xml" ));
        }
        
        string  settingsFile;
        bool    bDidWelcome;
        int     welcomeMillis;
        
    private:
        
        Settings(){};
        
        // C++ 11
        // =======
        // We can use the better technique of deleting the methods
        // we don't want.
        Settings(Settings const&)               = delete;
        void operator=(Settings const&)  = delete;
    };
    
    enum CursorType {
        CURSOR_STANDARD = 0,
        CURSOR_ADD,
        CURSOR_EDIT,
        CURSOR_DELETE,
        CURSOR_BEZIER
    };
    
    /**
     * @class CursorManager
     */
    class CursorManager {
    public:
        
        static CursorManager& get()
        {
            static CursorManager inst; // Guaranteed to be destroyed.
            static bool bInstance = false;
            
            if ( !bInstance ){
                bInstance = true;
                
                // build cursor images
                @autoreleasepool {
                    inst.addImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:ofToDataPath("cursors/cursor_add.pdf").c_str()]];
                    inst.delImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:ofToDataPath("cursors/cursor_delete.pdf").c_str()]];
                    inst.editImageA = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:ofToDataPath("cursors/cursor_edit.pdf").c_str()]];
                    
                    inst.bezierImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:ofToDataPath("cursors/cursor_bezier.pdf").c_str()]];
                    
                    
                    NSPoint offset = NSMakePoint(11,11);
                    
                    inst.cursorStandard = [NSCursor arrowCursor];
                    inst.cursorAdd = [[NSCursor alloc] initWithImage:inst.addImage hotSpot:offset ];
                    inst.cursorEdit = [[NSCursor alloc] initWithImage:inst.editImageA hotSpot:offset ];
                    inst.cursorDel = [[NSCursor alloc] initWithImage:inst.delImage hotSpot:offset ];
                    inst.cursorBezier = [[NSCursor alloc] initWithImage:inst.bezierImage hotSpot:offset ];
                }
            }
            
            return inst;
        }
        
        void setCursor( NSView * view, CursorType type ){
            switch (type){
                case CURSOR_STANDARD:
                    [view addCursorRect:rc::rectForAllScreens() cursor:cursorStandard];
                    [cursorStandard set];
                    break;
                    
                case CURSOR_ADD:
                    [view addCursorRect:rc::rectForAllScreens() cursor:cursorAdd];
                    [cursorAdd set];
                    break;
                case CURSOR_EDIT:
                    [view addCursorRect:rc::rectForAllScreens() cursor:cursorEdit];
                    [cursorEdit set];
                    break;
                case CURSOR_DELETE:
                    [view addCursorRect:rc::rectForAllScreens() cursor:cursorDel];
                    [cursorDel set];
                    break;
                case CURSOR_BEZIER:
                    [view addCursorRect:rc::rectForAllScreens() cursor:cursorBezier];
                    [cursorBezier set];
                    break;
            }
        }
        
    protected:
        // cursors
        NSCursor * cursorStandard, *cursorAdd, *cursorEdit, *cursorDel, *cursorBezier;
        
        // images
        NSImage *addImage, *delImage, *editImageA, *editImageB, *bezierImage;

        // saving this for later!
        NSImage * changeCursorColor( NSImage* img, float hue )
        {
            CIImage *inputImage = [[CIImage alloc] initWithData:[img TIFFRepresentation]];
            
            CIFilter *hueAdjust = [CIFilter filterWithName:@"CIHueAdjust"];
            [hueAdjust setValue: inputImage forKey: @"inputImage"];
            [hueAdjust setValue: [NSNumber numberWithFloat: hue]
                         forKey: @"inputAngle"];
            CIImage *outputImage = [hueAdjust valueForKey: @"outputImage"];
            
            NSImage *resultImage = [[NSImage alloc] initWithSize:[outputImage extent].size];
            NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:outputImage];
            [resultImage addRepresentation:rep];
            
            return resultImage;
            
        }
        
    private:
        CursorManager(){};
        CursorManager(Settings const&)               = delete;
        void operator=(Settings const&)  = delete;
    };
    
    /**
     * @class Events
     */
    class Events {
    public:
        
        static Events& get()
        {
            static Events inst; // Guaranteed to be destroyed.
            static bool bInstance = false;
            
            if ( !bInstance ){
                bInstance = true;
            }
            
            return inst;
        }
        
        ofEvent<Mode> modeChanged;
        
    private:
        Events(){};
        Events(Settings const&)               = delete;
        void operator=(Settings const&)  = delete;
    };
}