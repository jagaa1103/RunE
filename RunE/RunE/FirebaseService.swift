//
//  FirebaseService.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 5/3/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class FirebaseService: NSObject{
    static let sharedInstance = FirebaseService()
    var rootRef:Firebase?
    var firebaseKey: String = ""
    override init() {
        super.init()
        // Create a reference to a Firebase location
        self.firebaseKey = Keys.sharedInstance.getFirebaseKey()
        startService()
    }
    func startService(){
        self.rootRef = Firebase(url:"\(self.firebaseKey)")
        self.rootRef!.observeEventType(.Value, withBlock: { snapshot in
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                print("Connected")
            } else {
                print("Not connected")
            }
        })
    }
    
    func getFirebaseRef()->Firebase{
        return self.rootRef!
    }
    
    func saveLocationData(data:AnyObject, uid: String ,completion:(ret:Bool)->Void){
        let locationRef = Firebase(url: "\(self.firebaseKey)/location_data")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        let currentDate = dateFormatter.stringFromDate(NSDate())
        let locations: Dictionary = ["locations": data]
        
        locationRef.childByAppendingPath(uid).childByAppendingPath(currentDate).setValue(locations, withCompletionBlock: {
            (error:NSError?, ref:Firebase!) in
            if (error != nil) {
                print("Data could not be saved.")
                completion(ret:false)
            } else {
                print("Data saved successfully!")
                completion(ret:true)
            }
        })
    }
}