            //
//  Shape.cpp
//  MaskMask
//
//  Created by Brett Renfer on 5/19/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#include "Shape.h"

namespace mm {
    
#pragma mark Utils
    
    string cleanString( string aStr, string aReplace ) {
        ofStringReplace( aStr, aReplace, "");
        return aStr;
    }
    
    ofRectangle loadSvgBounds( string aPathToSvg ) {
        ofRectangle ret;
        
        ofFile mainXmlFile( aPathToSvg, ofFile::ReadOnly );
        ofBuffer tMainXmlBuffer( mainXmlFile );
        
        Poco::XML::DOMParser parser;
        Poco::XML::Document* document;
        
        try {
            document = parser.parseMemory( tMainXmlBuffer.getData(), tMainXmlBuffer.size() );
            document->normalize();
        } catch( exception e ) {
            short msg = atoi(e.what());
            ofLogError() << "loadFromBuffer " << msg << endl;
            if( document ) {
                document->release();
            }
            return ret;
        }
        
        if( document ) {
            Poco::XML::Element *svgNode     = document->documentElement();
            
            Poco::XML::Attr* viewBoxNode = svgNode->getAttributeNode("viewbox");
            
            ret.x        = ofToFloat( cleanString( svgNode->getAttribute("x"), "px") );
            ret.y        = ofToFloat( cleanString( svgNode->getAttribute("y"), "px" ));
            ret.width    = ofToFloat( cleanString( svgNode->getAttribute("width"), "px" ));
            ret.height   = ofToFloat( cleanString( svgNode->getAttribute("height"), "px" ));
            document->release();
        }
        
        return ret;
    }
    
#pragma mark Shape
    
    //--------------------------------------------------------------
    Shape::Shape(){
        path.setMode(ofPath::COMMANDS);
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
        
        myId = RUNNING_ID++;
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
            path.setMode(ofPath::COMMANDS);
            
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
                    if ( p.bUseBezier ){//&& prev != nullptr ){// n != nullptr && n->bUseBezier ){
                        path.bezierTo(p.bezierA, p.bezierB, p);
                        
                        debugLines.push_back(ofPath());
                        debugLines.back().lineTo(p.bezierA);
                        debugLines.back().lineTo(p);
                        debugLines.back().lineTo(p.bezierB);
//                    } else if ( prev != nullptr && prev->bUseBezier ){
//                        path.bezierTo(*prev, prev->bezierA, p);
                        
                    } else if ( prev != nullptr && prev->bUseBezier && !p.bUseBezier ) {
                        path.bezierTo(p, p, p);
                    } else {
                        path.lineTo(p);
                    }
                }
            }
            
            // draw "next" preview
            bool bNext = false;
            if ( nextPoint != ofVec2f(-1,-1) && drawMode == MODE_ADD ){
                if ( prevPoint.bUseBezier ) {
                    path.bezierTo(nextPoint, nextPoint, nextPoint);
                } else {
                    path.lineTo(nextPoint);
                }
                bNext = true;
            }
            
            // close path
            if ( points.size() != 0 ){
                auto & p = points[0];
                auto & e = !bNext ? points[points.size()-1] : nextPoint;
                if ( p.bUseBezier ){
                    path.bezierTo(p.bezierA, p.bezierB, p);
                    
                    debugLines.push_back(ofPath());
                    debugLines.back().lineTo(p.bezierA);
                    debugLines.back().lineTo(p);
                    debugLines.back().lineTo(p.bezierB);
                    
                } else if ( e.bUseBezier ){
                    path.bezierTo(p,p, p);
                } else {
                    path.lineTo(p);
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
                path.setFillColor(fillColor);
            }
            
            ofPushStyle();
            bool bFlip = true;
            ofNoFill();
            for (auto & v : points ){
                ofSetColor(bFlip ? SHAPE_SQUARE_COLOR_A : SHAPE_SQUARE_COLOR_B );
                ofDrawCircle(v, SHAPE_SQUARE_SIZE);
                if ( v.bUseBezier ){
                    ofSetColor(bFlip ? SHAPE_BEZIER_COLOR_A : SHAPE_BEZIER_COLOR_B);
                    ofDrawRectangle(v.bezierA, SHAPE_BEZIER_SIZE, SHAPE_BEZIER_SIZE);
                    ofDrawRectangle(v.bezierB, SHAPE_BEZIER_SIZE, SHAPE_BEZIER_SIZE);
                }
                bFlip = !bFlip;
            }
            
            ofFill();
            for (auto & path : debugLines ){
                path.setFilled(false);
                path.setStrokeWidth(1.);
                path.setStrokeColor(ofColor::white);
                path.draw();
            }
            
            ofPopStyle();
            if ( selected != NULL ){
                ofDrawCircle(*selected, SHAPE_SQUARE_SIZE_SELECTED);
            }
            
            if ( drawMode == MODE_EDIT ){
                ofDrawCircle(pointToAdd, SHAPE_SQUARE_SIZE_SELECTED);
            }
        }
        
        ofPopMatrix();
    }
    
    //--------------------------------------------------------------
    void Shape::addVertex( const ofVec2f & p ){
        points.push_back(Point());
        points.back().set(p);
        points.back().bezierA.set(points.size() == 1 ? p : prevPoint);
        points.back().bezierB.set(p);
        bChanged = true;
        nextPoint.set(-1,-1);
        prevPoint.set(p);
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
    Point * Shape::getSelected() const
    {
        return selected;
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
    bool Shape::close(){
        if ( points.size() > 2 ){
            path.close();
            return true;
        } else {
            return false;
        }
    }
    
    //--------------------------------------------------------------
    bool Shape::mousePressed( ofMouseEventArgs & e, mm::Mode mode ){
        bool bFound = false;
        if ( mode == MODE_EDIT_DEL ){
            // look for a point to delete
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
            // selecting
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
                if ( mode >= MODE_ADD  ){
                    if ( pointToAdd.distance(e) < SHAPE_SQUARE_SIZE ){
                        Point p;
                        p.set(pointToAdd);
                        p.bezierA.set(pointToAdd);
                        p.bezierB.set(pointToAdd);
                        
                        nearestIndex = getInsertIndex(pointToAdd);
                        
                        points.insert(points.begin() + nearestIndex + 1, p);
                        
                        bChanged = true;
                        bFound = true;
                    }
                }
                
                // nah? OK are we trying to drag?
                if ( !bFound && path.getOutline().size() > 0 && mode > MODE_ADD ){
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
        
        // set current point, if we have one
        if ( selected != NULL && bMouseDown ){
            selected->set(e);
            
            bChanged = true;
            
        // moving whole shape
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
            auto poly = path.getOutline()[0];
            poly.close();
            
            pointToAdd.set( poly.getClosestPoint(e, &nearestIndex) );
//            cout << "1:"<<nearestIndex << endl;
//            nearestIndex = getInsertIndex( pointToAdd );
//            cout << "2:"<<nearestIndex << endl;
        }
    }
    
    
    //--------------------------------------------------------------
    void Shape::setFillColor( ofColor fill ){
        fillColor.set(fill);
        
        fillColor.setHue(ofWrap(fillColor.getHue() + myId * 10,0,255));
        selectedColor.set(fillColor);
        selectedColor.a = 100;
    }
    
    //--------------------------------------------------------------
    void Shape::import( string svgFile ){
        ofxSvgLoader toImport;
        bool loaded = toImport.load(svgFile);
        if ( loaded ){
            // for some reason, SVGs are upside down (or our whole vp is?)
            auto b = loadSvgBounds(svgFile);
            ofPoint t(0, b.height);
            ofPoint flip( 1, -1);
            
            for ( auto & p : toImport.getElementsForType<ofxSvgPath>() ){
                ofVec2f src;
                for ( auto & c : p->path.getCommands() ){
                    
                    if ( c.type == ofPath::Command::close ){
//                    } else if ( c.type == ofPath::Command::moveTo ){
//                        src.set(c.to);
                    } else {
                        points.push_back(Point());
                        points.back().set(t +  c.to * flip );
                        points.back().bezierA.set( t + c.cp1 * flip );
                        points.back().bezierB.set( t+ c.cp2 * flip );
                        points.back().bUseBezier = c.type == ofPath::Command::bezierTo;
                    }
                }
                
                bChanged = true;
            }
        } else {
            ofLogError()<<"[MaskMask] SVG import failed :(";
        }
    }
    
    //--------------------------------------------------------------
    int Shape::getInsertIndex( const ofVec2f & target ){
        
        auto & poly = path.getOutline()[0];
        int ret = 0;
        
        int cur_closest = 0;
        
        for ( size_t i=0; i<points.size(); i++){
            ofPath segment;
            
            auto & p = points[i];
            Point * prev = nullptr;
            Point * next = nullptr;
            
            segment.moveTo(p);
            
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
            
            if ( p.bUseBezier && prev != nullptr ){// n != nullptr && n->bUseBezier ){
                segment.bezierTo(*prev, p.bezierB, p);
//            } else if ( prev != nullptr && prev->bUseBezier ){
//                segment.bezierTo(*prev, prev->bezierA, p);
                
            } else {
                segment.lineTo(p);
            }
            
            if ( next != nullptr ){
                if ( next->bUseBezier  ){// n != nullptr && n->bUseBezier ){
                    segment.bezierTo(p, next->bezierB, *next);
                } else if ( p.bUseBezier ){
                    segment.bezierTo(p, p.bezierA, *next);
                    
                } else {
                    segment.lineTo(*next);
                }
            }
            
            if ( i == points.size() -1 ){
                auto & p = points[0];
                auto & e = points[points.size()-1];
                if ( p.bUseBezier ){
                    segment.bezierTo(e, p.bezierA, p);
                } else if ( e.bUseBezier ){
                    segment.bezierTo(e, e.bezierA, p);
                } else {
                    //                    path.lineTo(p);
                }
            }
            
            auto poly = segment.getOutline()[0];
            unsigned int whichClosest = 0;
            auto closestP = poly.getClosestPoint(target, &whichClosest);
            
            if ( abs(closestP.distance(target)) > 0.001  ){
            } else {
                ret = i;
                return ret;
            }
        }
        
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