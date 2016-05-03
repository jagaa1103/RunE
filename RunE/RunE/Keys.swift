//
//  Keys.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 5/3/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation

class Keys: NSObject {
    var FireBaseKey:String = ""
    static let sharedInstance = Keys()
    override init(){
        super.init()
        getDictionary()
    }
    
    func getDictionary(){
        let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        self.FireBaseKey = (dictionary?.objectForKey("FirebaseKey") as? String)!
    }
    
    func getFirebaseKey()->String{
        return FireBaseKey
    }
}
