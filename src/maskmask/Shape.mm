//
//  Shape.cpp
//  MaskMask
//
//  Created by Brett Renfer on 5/19/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#include "Shape.h"

namespace mm {
    
#pragma mark Shape
    
    //--------------------------------------------------------------
    Shape::Shape(){
        path.setMode(ofPath::POLYLINES);
        path.setFillColor(SHAPE_COLOR);
        selected = NULL;
        bMouseDown = false;
        bShapeSelected = false;
        bChanged = false;
        bKillMe = false;
    }
    
    //--------------------------------------------------------------
    Shape::~Shape(){
    }
    
    //--------------------------------------------------------------
    void Shape::draw( mm::Mode drawMode ){
        if ( bChanged ){
            path.clear();
            path.setMode(ofPath::POLYLINES);
            
            int ind = 0;
            for ( auto & p : points ){
                if ( ind == 0 ){
                    path.lineTo(p);
                } else {
                    if ( p.bUseBezier ){
                        path.bezierTo(p.bezierA, p.bezierB, p);
                    } else {
                        path.lineTo(p);
                    }
                }
                ind++;
            }
            if ( points.size() != 0 ){
                auto & p = points[0];
                if ( p.bUseBezier ){
                    path.bezierTo(p.bezierA, p.bezierB, p);
                } else {
                    //                    path.lineTo(p);
                }
                path.close();
            }
            bChanged  = false;
        }
        ofPushMatrix();
        path.draw();
        
        if ( drawMode >= MODE_ADD ){
            if ( bShapeSelected ){
                path.setFillColor(SHAPE_COLOR_SELECTED);
            } else {
                path.setFillColor(SHAPE_COLOR);
            }
            
            ofPushStyle();
            bool bFlip = true;
            for (auto & v : points ){
                ofSetColor(bFlip ? SHAPE_SQUARE_COLOR_A : SHAPE_SQUARE_COLOR_B );
                ofRect(v, SHAPE_SQUARE_SIZE, SHAPE_SQUARE_SIZE);
                if ( v.bUseBezier ){
                    ofSetColor(bFlip ? SHAPE_BEZIER_COLOR_A : SHAPE_BEZIER_COLOR_B);
                    ofRect(v.bezierA, SHAPE_BEZIER_SIZE, SHAPE_BEZIER_SIZE);
                    ofRect(v.bezierB, SHAPE_BEZIER_SIZE, SHAPE_BEZIER_SIZE);
                }
                bFlip = !bFlip;
            }
            ofPopStyle();
            if ( selected != NULL ){
                ofRect(*selected, SHAPE_SQUARE_SIZE_SELECTED, SHAPE_SQUARE_SIZE_SELECTED);
            }
            
            if ( drawMode == MODE_EDIT ){
                ofRect(pointToAdd, SHAPE_SQUARE_SIZE_SELECTED, SHAPE_SQUARE_SIZE_SELECTED);
            }
        }
        
        ofPopMatrix();
    }
    
    //--------------------------------------------------------------
    void Shape::addVertex(ofVec2f & p ){
        points.push_back(Point());
        points.back().set(p);
        points.back().bezierA.set(p);
        points.back().bezierB.set(p);
        bChanged = true;
    }
    
    //--------------------------------------------------------------
    void Shape::deleteSelected(){
        if ( selected != NULL ){
            for ( int i=0; i<points.size(); i++){
                if ( points[i] == *selected){
                    points.erase(points.begin() + i );
                    selected = NULL;
                    bChanged = true;
                    break;
                }
            }
        }
    }
    
    //--------------------------------------------------------------
    bool Shape::shouldDelete(){
        return bKillMe;
    }
    
    //--------------------------------------------------------------
    void Shape::close(){
        path.close();
    }
    
    //--------------------------------------------------------------
    bool Shape::mousePressed( ofMouseEventArgs & e, mm::Mode mode ){
        bool bFound = false;
        if ( mode == MODE_EDIT_DEL ){
            for ( auto & v : points ){
                if ( v.distance(e) < SHAPE_SQUARE_SIZE ){
                    selected = &v;
                    bFound = true;
                    break;
                }
            }
            if ( bFound ){
                deleteSelected();
            } else {
                selected = NULL;
                if ( path.getOutline().size() > 0 ){
                    if ( path.getOutline()[0].inside(e.x,e.y) ){
                        bShapeSelected = true;
                        pointPressed.set(e.x,e.y);
                        bFound = true;
                        bKillMe = true;
                    } else {
                        bShapeSelected = false;
                    }
                } else {
                    bShapeSelected = false;
                }
            }
            
        } else {
            for ( auto & v : points ){
                if ( v.distance(e) < SHAPE_SQUARE_SIZE ){
                    selected = &v;
                    if ( ofGetKeyPressed( MM_KEY_BEZIER )){
                        v.bUseBezier = !v.bUseBezier;
                        bChanged = true;
                    }
                    bFound = true;
                } else if ( v.bezierA.distance(e) < SHAPE_SQUARE_SIZE ){
                    selected = &v.bezierA;
                    bFound = true;
                } else if ( v.bezierB.distance(e) < SHAPE_SQUARE_SIZE ){
                    selected = &v.bezierB;
                    bFound = true;
                }
            }
            if ( !bFound ){
                selected = NULL;
                // first, are we adding new point?
                if ( mode == MODE_EDIT  ){
                    if ( pointToAdd.distance(e) < SHAPE_SQUARE_SIZE ){
                        Point p;
                        p.set(pointToAdd);
                        p.bezierA.set(pointToAdd);
                        p.bezierB.set(pointToAdd);
                        int index = nearestIndex;
                        
                        // hm
                        auto & tp = points[nearestIndex];
                        if ( tp.x - p.x < 0 ){//|| tp.y - p.y > 0 ){
                            //nearestIndex--;
                        }
                        nearestIndex %= points.size();
                        
                        points.insert(points.begin() + nearestIndex, p);
                        bChanged = true;
                        bFound = true;
                    }
                }
                
                // nah? OK are we trying to drag?
                if ( !bFound && path.getOutline().size() > 0 ){
                    if ( path.getOutline()[0].inside(e.x,e.y) ){
                        bShapeSelected = true;
                        pointPressed.set(e.x,e.y);
                        bFound = true;
                    } else {
                        bShapeSelected = false;
                    }
                } else {
                    bShapeSelected = false;
                }
            }
            bMouseDown = true;
        }
        return bFound;
    }
    
    //--------------------------------------------------------------
    void Shape::mouseDragged( ofMouseEventArgs & e ){
        if ( selected != NULL && bMouseDown ){
            selected->set(e);
            bChanged = true;
        } else if ( bShapeSelected ){
            for ( auto & p : points ){
                p += (e-pointPressed);
                p.bezierA += (e-pointPressed);
                p.bezierB += (e-pointPressed);
            }
            bChanged = true;
            pointPressed.set(e.x,e.y);
        }
    }
    
    //--------------------------------------------------------------
    void Shape::mouseReleased( ofMouseEventArgs & e ){
        selected = NULL;
        bMouseDown = false;
        bShapeSelected = false;
    }
    
    //--------------------------------------------------------------
    void Shape::mouseMoved( ofMouseEventArgs & e, Mode mode ){
        bool bFound = false;
        for ( auto & v : points ){
            if ( v.distance(e) < SHAPE_SQUARE_SIZE ){
                selected = &v;
                bFound = true;
            }
        }
        if ( !bFound ) selected = NULL;
        if ( mode == MODE_EDIT &&  path.getOutline().size() > 0 ){
            pointToAdd.set( path.getOutline()[0].getClosestPoint(e,&nearestIndex) );
        }
    }
}