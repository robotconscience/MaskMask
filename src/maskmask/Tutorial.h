// basic "welcome" tutorial

#pragma once

#include "ofxSvg.h"
#include "MMConstants.h"

namespace mm {

    class TutorialScreen {
    public:
        
        void setup( string file ){
            svg.load(file);
            alpha = 255;
        }
        
        void draw(){
            ofPushMatrix();
            
            // (hopefully) temp hack
            ofTranslate(ofGetWidth()/2.0, ofGetHeight()/2.0);
            ofScale(1,-1);
            ofTranslate(-ofGetWidth()/2.0, -ofGetHeight()/2.0);
            ofPushStyle();
            float scale = fmax(ofGetWidth() / 1920., ofGetHeight()/1080.);
            ofScale(scale,scale);
            ofSetColor(255,alpha);
            svg.draw();
            ofPopStyle();
            ofPopMatrix();
        }
        
        float alpha;
        
    protected:
        
        ofxSVG svg;
    };

    class Tutorial {
    public:
        
        bool setup( string directory="tutorial"){
            // first, check for settings: do we need to do this?
            bActive = !Settings::get().bDidWelcome;
            
            if ( bActive ){
                string dir = ofToDataPath(directory);
                ofDirectory lister;
                int nSvgs = lister.listDir(dir);
                
                activeScreen = 0;
                
                for (int i=0; i<nSvgs; i++){
                    screens.push_back(TutorialScreen());
                    screens.back().setup( lister.getPath(i) );
                }
                lastChanged = ofGetElapsedTimeMillis();
            }
            
            return bActive;
        }
        
        bool active(){
            return bActive;
        }
        
        bool draw(){
            if ( active()){
                // first, time
                uint64_t time = ofGetElapsedTimeMillis();
                int     rate  = Settings::get().welcomeMillis;
                
                float alpha = ofMap( time-lastChanged, 0, rate, 255, 0 );
                
                screens[activeScreen].draw();
                
                if ( time - lastChanged > rate ){
                    lastChanged = time;
                    activeScreen++;
                    if ( activeScreen >= screens.size()){
                        bActive = false;
                        
                        Settings::get().bDidWelcome = true;
                        Settings::get().save();
                        return false;
                    }
                }
            }
            return true;
        }
        
        vector<TutorialScreen> screens;
        
    protected:
        
        bool bActive;
        int activeScreen;
        
        // timing
        uint64_t lastChanged;
    };
}