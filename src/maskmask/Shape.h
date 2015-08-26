//
//  Shape.h
//  MaskMask
//
//  Created by Brett Renfer on 5/19/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#pragma once

#include "ofMain.h"
#include "MMConstants.h"

namespace mm {
    
    enum PointMode {
        EDIT_POINT = 0,
        EDIT_BEZIER,
        EDIT_BEZIER_A,
        EDIT_BEZIER_B
    };
    
    class Point : public ofVec3f {
    public:
        Point(){ bUseBezier = false; mode = EDIT_POINT; };
        ofVec3f bezierA, bezierB;
        bool bUseBezier;
        
        void set(const ofVec3f & next ){
            switch ( mode ){
                case EDIT_BEZIER: {
                    
                    bezierA.set(next);
                    ofVec3f dist = *this + (*this - next);
                    
                    bezierB.set(dist);
                }
                    break;
                case EDIT_BEZIER_A:{
                    bezierA.set(next);
                    
                }
                    break;
                case EDIT_BEZIER_B:{
                    bezierB.set(next);
                    
                }
                    break;
                    
                case EDIT_POINT:{
                    ofVec3f diff = (*this-next);
                    ofVec3f::set(next);
                    if ( bUseBezier ){
                        bezierA -= diff;
                        bezierB -= diff;
                    }
                }
                break;
                default:
                    ofVec3f::set(next);
            }
        }
        void set(float x, float y ){
            if ( bUseBezier ){
                bezierA.set(x,y);
            } else {
                ofVec3f::set(x,y);
            }
        }
        
        PointMode mode;
    };
    
    class Shape {
    public:
        Shape();
        ~Shape();
        void draw( mm::Mode drawMode );
        void addVertex(const ofVec2f & p );
        void removeLastVertex();
        void setNextPoint( const ofVec2f & p);
        void deleteSelected();
        void close();
        
        bool mousePressed( ofMouseEventArgs & e, mm::Mode mode = MODE_RENDER );
        void mouseDragged( ofMouseEventArgs & e, mm::Mode mode = MODE_RENDER );
        void mouseReleased( ofMouseEventArgs & e, mm::Mode mode = MODE_RENDER );
        void mouseMoved( ofMouseEventArgs & e, mm::Mode mode = MODE_RENDER );
        
        bool shouldDelete();
        
        vector<Point> & getPoints();
        
        // utils
        mutex mux;
        int getClosestIndex( const ofVec3f & p );
        
    protected:
        Point * selected;
//        ofVec3f * selectedComp;
        ofVec2f pointPressed, originalCenter; // where shape was clicked
        bool bMouseDown, bShapeSelected;
        
        vector<Point> points;
        vector<ofPath> debugLines;
        Point nextPoint;
        
        ofVec2f pointToAdd;
        unsigned int nearestIndex;
        
        ofPath path;
        bool bChanged, bKillMe;
        
    };
}