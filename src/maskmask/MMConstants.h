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
    
    // cursors
    
    static NSCursor * cursorStandard, *cursorAdd, *cursorEditA, *cursorEditD, *cursorDel;
}