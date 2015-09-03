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
        
        selected = nullptr;
//        selectedComp = nullptr;
        fillColor.set(SHAPE_COLOR);
        selectedColor.set(SHAPE_COLOR_SELECTED);
    }
    
    //--------------------------------------------------------------
    Shape::~Shape(){
    }
    
    //--------------------------------------------------------------
    void Shape::draw( mm::Mode drawMode ){
        static mm::Mode lastMode = MODE_WELCOME;
        if ( drawMode != lastMode ){
            bChanged = true;
            lastMode = drawMode;
        }
        if ( bChanged ){
            path.clear();
            path.setMode(ofPath::POLYLINES);
            
            debugLines.clear();
            
            int ind = 0;

            for ( size_t i=0; i<points.size(); i++){
                auto & p = points[i];
                Point * prev = nullptr;
                Point * next = nullptr;
                
                if ( i != 0 ){
                    prev = &points[i-1];
                } else if ( points.size() > 1 ){
                    prev = &points[ points.size() - 1 ];
                }
                if ( i +1 < points.size() ){
                    next = &points[i+1];
                } else if ( points.size() > 1 ){
                    next = &points[0];
                }
                
                if ( i == 0 ){
                    path.moveTo(p);
                } else {
                    if ( p.bUseBezier && prev != nullptr ){// n != nullptr && n->bUseBezier ){
                        path.quadBezierTo(*prev, p.bezierB, p);
                        
                        debugLines.push_back(ofPath());
                        debugLines.back().lineTo(p.bezierA);
                        debugLines.back().lineTo(p);
                        debugLines.back().lineTo(p.bezierB);
                    } else if ( prev != nullptr && prev->bUseBezier ){
                        path.quadBezierTo(*prev, prev->bezierA, p);
                        
                    } else {
                        path.lineTo(p);
                    }
                }
            }
            
            // draw "next" preview
            if ( nextPoint != ofVec2f(-1,-1) && drawMode == MODE_ADD ){
                path.lineTo(nextPoint);
            }
            
            // close path
            if ( points.size() != 0 ){
                auto & p = points[0];
                auto & e = points[points.size()-1];
                if ( p.bUseBezier ){
                    path.quadBezierTo(e, p.bezierA, p);
                } else if ( e.bUseBezier ){
                    path.quadBezierTo(e, e.bezierA, p);
                } else {
                    //                    path.lineTo(p);
                }
//                path.close();
            }
            bChanged  = false;
        }
        ofPushMatrix();
        path.draw();
        
        if ( drawMode >= MODE_ADD ){
            if ( bShapeSelected ){
                path.setFillColor(SHAPE_COLOR_SELECTED);
            } else {
                path.setFillColor(fillColor);
            }
            
            ofPushStyle();
            bool bFlip = true;
            for (auto & v : points ){
                ofSetColor(bFlip ? SHAPE_SQUARE_COLOR_A : SHAPE_SQUARE_COLOR_B );
                ofDrawRectangle(v, SHAPE_SQUARE_SIZE, SHAPE_SQUARE_SIZE);
                if ( v.bUseBezier ){
                    ofSetColor(bFlip ? SHAPE_BEZIER_COLOR_A : SHAPE_BEZIER_COLOR_B);
                    ofDrawRectangle(v.bezierA, SHAPE_BEZIER_SIZE, SHAPE_BEZIER_SIZE);
                    ofDrawRectangle(v.bezierB, SHAPE_BEZIER_SIZE, SHAPE_BEZIER_SIZE);
                }
                bFlip = !bFlip;
            }
            
            for (auto & path : debugLines ){
                path.setFilled(false);
                path.setStrokeWidth(1.);
                path.setStrokeColor(ofColor::white);
                path.draw();
            }
            
            ofPopStyle();
            if ( selected != NULL ){
                ofDrawRectangle(*selected, SHAPE_SQUARE_SIZE_SELECTED, SHAPE_SQUARE_SIZE_SELECTED);
            }
            
            if ( drawMode == MODE_EDIT ){
                ofDrawRectangle(pointToAdd, SHAPE_SQUARE_SIZE_SELECTED, SHAPE_SQUARE_SIZE_SELECTED);
            }
        }
        
        ofPopMatrix();
    }
    
    //--------------------------------------------------------------
    void Shape::addVertex( const ofVec2f & p ){
        points.push_back(Point());
        points.back().set(p);
        points.back().bezierA.set(p);
        points.back().bezierB.set(p);
        bChanged = true;
        
        nextPoint.set(-1,-1);
    }
    
    //--------------------------------------------------------------
    void Shape::removeLastVertex(){
        if ( points.size() != 0 ){
            points.pop_back();
        }
    }
    
    //--------------------------------------------------------------
    void Shape::setNextPoint( const ofVec2f & p){
        nextPoint.set(p);
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
    std::vector<Point> & Shape::getPoints(){
//        unique_lock<mutex> lock(mux);
        return points;
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
                    selected->mode = EDIT_POINT;
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
                    selected->mode = EDIT_POINT;
                    
                    if ( ofGetKeyPressed( MM_KEY_BEZIER )){
                        v.bUseBezier = !v.bUseBezier;
                        selected = &v;
                        selected->mode = EDIT_BEZIER;
                        bChanged = true;
                    }
                    bFound = true;
                } else if ( v.bezierA.distance(e) < SHAPE_SQUARE_SIZE ){
                    selected = &v;
                    selected->mode = EDIT_BEZIER_A;
                    bFound = true;
                } else if ( v.bezierB.distance(e) < SHAPE_SQUARE_SIZE ){
                    selected = &v;
                    bFound = true;
                    selected->mode = EDIT_BEZIER_B;
                }
            }
            if ( !bFound ){
                selected = nullptr;
//                selectedComp =  nullptr;
                // first, are we adding new point?
                if ( mode == MODE_EDIT  ){
                    if ( pointToAdd.distance(e) < SHAPE_SQUARE_SIZE ){
                        Point p;
                        p.set(pointToAdd);
                        p.bezierA.set(pointToAdd);
                        p.bezierB.set(pointToAdd);
                        
//                        nearestIndex = getLineSegment(pointToAdd)[0];   
                        
                        points.insert(points.begin() + nearestIndex + 1, p);
                        
                        cout << "INSERT AFTER "<<nearestIndex<<endl;
                        
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
    void Shape::mouseDragged( ofMouseEventArgs & e, mm::Mode mode ){
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
        } else {
            // hm, kind of a hack to decide if we just added
            // a point or not!
            
            auto & v = points.back();
            if ( mode == MODE_ADD && points.size() != 0 ){
                if ( !v.bUseBezier ){
                    v.bUseBezier = !v.bUseBezier;
                    selected = &v;
                    selected->mode = EDIT_BEZIER;
                } else {
                    if ( selected != NULL){
                        selected->set(e);
                    }
                }
                bChanged = true;
            }
        }
    }
    
    //--------------------------------------------------------------
    void Shape::mouseReleased( ofMouseEventArgs & e, mm::Mode mode ){
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
                break;
            }
        }
        if ( !bFound ) selected = NULL;
        if ( mode == MODE_EDIT &&  path.getOutline().size() > 0 ){
            auto & poly = path.getOutline()[0];
            
            pointToAdd.set( poly.getClosestPoint(e, &nearestIndex) );
//            cout << "1:"<<nearestIndex << endl;
            nearestIndex = getInsertIndex( pointToAdd );
//            cout << "2:"<<nearestIndex << endl;
        }
    }
    
    
    //--------------------------------------------------------------
    void Shape::setFillColor( ofColor fill ){
        fillColor.set(fill);
    }
    
    //--------------------------------------------------------------
    int Shape::getInsertIndex( const ofVec2f & p ){
        float dist = FLT_MAX;
        int closest = -1;
        
        int index = 0;
        for ( auto & v : points ){
            float nd = v.distance(p);
            if ( nd < dist ){
                closest = index;
                dist = nd;
            }
            index++;
        }
        
        int next = closest + 1 < points.size() ? closest + 1 : 0;
        int prev = closest -1 >= 0 ? closest - 1 : points.size()-1;
        
        ofVec2f cP = points[closest];
        ofVec2f nP = points[next];
        ofVec2f pP = points[prev];
        
        // closest = nearest point
        // are we bettwen closest and next or closest and prev?
        
        int ret = closest;
        
        cout<<ofSign(p.x - cP.x)<<":"<<ofSign(p.x - nP.x)<<":"<<ofSign(p.x - pP.x)<<endl;
        cout<<ofSign(p.y - cP.y)<<":"<<ofSign(p.y - nP.y)<<":"<<ofSign(p.x - pP.x)<<endl;
        
//        cout << dC <<":"<<dP<<":"<<dN<<endl;
        
        
        return ret;
    }
    
    //--------------------------------------------------------------
    vector<int> Shape::getLineSegment( const ofVec2f & p ){
        
    }
    
    //--------------------------------------------------------------
    bool Shape::inside( const ofVec2f & p, mm::Mode drawMode ){
        static vector<ofPoint> tempPoints;
        tempPoints.clear();
        for ( auto & p : points ){
            tempPoints.push_back(ofVec2f(p));
        }
        
//        bool insideShape = ofInsidePoly(p, tempPoints);
        
        bool insideShape = path.getOutline()[0].inside(p);
        
        return insideShape;//drawMode == MODE_RENDER ? !insideShape : insideShape;
    }
}