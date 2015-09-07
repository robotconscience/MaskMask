//
//  MMConstants.h
//  MaskMask
//
//  Created by Brett Renfer on 5/14/15.
//
//

#pragma once

#include <Cocoa/Cocoa.h>

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
    
    static const char MM_KEY_BEZIER = 'z';
    
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
    
    // cursors
    static NSCursor * cursorStandard, *cursorAdd, *cursorEditA, *cursorEditD, *cursorDel;
    
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
                settings.load(ofToDataPath( "settings.xml" ));
                
                settings.setTo("settings");
                inst.settingsFile = settings.getValue("settingsFile");
                settings.setTo("welcome");
                inst.bDidWelcome = settings.getBoolValue("didWelcome");
                inst.welcomeMillis = settings.getIntValue("timing");
                settings.setToParent();
                
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
}