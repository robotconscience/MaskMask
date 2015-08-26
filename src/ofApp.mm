#include "ofApp.h"
#include "ofxCocoaWindow.h"

//--------------------------------------------------------------
void ofApp::setup(){
    ofBackground(ofColor(0,0));
    
    auto * window = static_cast<ofxCocoaWindow *>(ofGetWindowPtr());
    
    [window->getNSWindow() setIgnoresMouseEvents:YES];
    [window->getNSWindow() makeKeyAndOrderFront:nil];
    
    ofSetDataPathRoot("../Resources/");
    
    manager.setup();
}

//--------------------------------------------------------------
void ofApp::update(){
}

//--------------------------------------------------------------
void ofApp::draw(){

}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
