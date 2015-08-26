//
//  ToolBar.cpp
//  MaskMask
//
//  Created by Brett Renfer on 5/19/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#include "ToolBar.h"

namespace mm {
    
    
#pragma mark Tool
    
    //--------------------------------------------------------------
    void Tool::load( string image_path ){
        toolImage.load( ofToDataPath(image_path) );
    }
    
    //--------------------------------------------------------------
    void Tool::draw(){
        toolImage.draw(this->x, this->y, this->width, this->height);
        FontManager::get().font.drawString(getModeAsString(myMode), this->x + this->width + TOOLBAR_PADDING/2., this->y + TOOLBAR_FONT_SIZE);
    }
    
#pragma mark ToolBar
    
    //--------------------------------------------------------------
    void ToolBar::setup(){
        bDragging = false;
        
        tools.push_back(Tool());
        tools.back().load("tools/tool_add.png");
        tools.back().myMode = MODE_ADD;
        
        tools.push_back(Tool());
        tools.back().load("tools/tool_edit.png");
        tools.back().myMode = MODE_EDIT;
        
        tools.push_back(Tool());
        tools.back().load("tools/tool_delete.png");
        tools.back().myMode = MODE_EDIT_DEL;
        
        float x = TOOLBAR_PADDING;
        float y = TOOLBAR_PADDING + TOOLBAR_FONT_SIZE * 2;
        
        for ( auto & t : tools ){
            t.set(x, y, TOOLBAR_TOOL_SIZE, TOOLBAR_TOOL_SIZE );
            y += TOOLBAR_TOOL_SIZE + TOOLBAR_PADDING/2.;
        }
        this->width = FontManager::get().fontBold.stringWidth("Shape Tools") + TOOLBAR_PADDING * 2;
        this->height = y + TOOLBAR_PADDING/2.;
    }
    
    //--------------------------------------------------------------
    void ToolBar::draw( ofEventArgs & e ){
        cout << "DRAW"<<endl;
        ofPushMatrix();
        ofTranslate(this->x, this->y);
        ofPushStyle();
        ofSetColor(TOOLBAR_BG_COLOR);
        ofDrawRectangle(0,0,this->width,this->height);
        
        ofSetColor( ofColor::white );
        FontManager::get().fontBold.drawString("Shape Tools", TOOLBAR_PADDING,TOOLBAR_PADDING+TOOLBAR_FONT_SIZE);
        
        for ( auto & t : tools ){
            t.draw();
        }
        
        ofPopStyle();
        ofPopMatrix();
    }
    
    //--------------------------------------------------------------
    bool ToolBar::mousePressed( ofMouseEventArgs & e ){
        ofVec2f pt = e - ofVec2f(this->x, this->y);
        for ( auto & t : tools ){
            if ( t.inside(pt)){
                ofNotifyEvent(onChangeTool, t.myMode, this);
                return true;
            }
        }
        
        // got this far, are we moving the menu?
        if ( inside(e) ){
            bDragging = true;
            dragPoint.set(pt);
            return true;
        }
        
        return false;
    }
    
    //--------------------------------------------------------------
    void ToolBar::mouseDragged( ofMouseEventArgs & e ){
        if ( bDragging ){
            this->x = e.x - dragPoint.x;
            this->y = e.y - dragPoint.y;
        }
    }
    
    //--------------------------------------------------------------
    void ToolBar::mouseReleased( ofMouseEventArgs & e ){
        bDragging = false;
    }
    
    //--------------------------------------------------------------
    void ToolBar::mouseMoved( ofMouseEventArgs & e ){
        
    }
    
    //--------------------------------------------------------------
    void ToolBar::windowResized( ofResizeEventArgs & e ){
        
    }
}