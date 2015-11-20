//
//  Helper.h
//  MaskMask
//
//  Created by Brett Renfer on 11/20/15.
//
//

#pragma once
#include "ofMain.h"
#include "MMConstants.h"

namespace mm {
    class Helper
    {
    public:
        
        void setup( string settingsFile="documentation/helper.xml"){
            ofXml xml;
            bool bLoaded = xml.load(ofToDataPath(settingsFile));
            if ( bLoaded ){
                xml.setTo("help");
                int numEntries = xml.getNumChildren();
                for (int i=0; i<numEntries; i++){
                    Mode e = (Mode) i;
                    xml.setToChild(i);
                    entries[e] = xml.getValue("title") +"\n"+ xml.getValue("copy");
                    xml.setToParent();
                }
                xml.setToParent();
            }
        }
        
        string getEntry ( Mode m ){
            return entries[m];
        }
        
//        map<HelperEntry,string> entries;
        map<Mode, string> entries;
    };
}
