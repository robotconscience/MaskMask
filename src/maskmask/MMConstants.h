//
//  MMConstants.h
//  MaskMask
//
//  Created by Brett Renfer on 5/14/15.
//
//

#pragma once

namespace mm {
    static const int SHAPE_SQUARE_SIZE = 10;
    static const int SHAPE_SQUARE_SIZE_SELECTED = 12;
    static const int SHAPE_BEZIER_SIZE = 5;
    
    static const ofColor SHAPE_SQUARE_COLOR_A(0,255,0);
    static const ofColor SHAPE_SQUARE_COLOR_B(0,0,255);
    static const ofColor SHAPE_BEZIER_COLOR_A(255,0,255);
    static const ofColor SHAPE_BEZIER_COLOR_B(0,255,255);
    
    static const ofColor SHAPE_COLOR(255,0,0);
    static const ofColor SHAPE_COLOR_SELECTED(255,255,0,150);
    
    static const char MM_KEY_BEZIER = 'z';
    
    // App Mode
    enum Mode {
        MODE_WELCOME = 0,
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
    
    // toolbar
    static const ofColor TOOLBAR_BG_COLOR( ofColor::fromHex(0x6db4d6) );
    
    static const string TOOLBAR_FONT = "fonts/maax.otf";
    static const string TOOLBAR_FONT_BOLD = "fonts/maaxbold.otf";

    static const int TOOLBAR_FONT_SIZE = 15;
    static const int TOOLBAR_PADDING = 15;
    static const int TOOLBAR_TOOL_SIZE = 40;
    
    // phontz
    class FontManager {
    public:
        static FontManager & get(){
            static FontManager me;
            if ( !me.fontBold.isLoaded()){
                me.fontBold.loadFont( ofToDataPath(TOOLBAR_FONT_BOLD), TOOLBAR_FONT_SIZE );
            }
            
            if ( !me.font.isLoaded()){
                me.font.loadFont( ofToDataPath(TOOLBAR_FONT), TOOLBAR_FONT_SIZE );
            }
            return me;
        }
        
        ofTrueTypeFont font, fontBold;

    protected:
        
        FontManager(){
            
        }
    };
}