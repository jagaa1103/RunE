//
//  MotionService.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 4/27/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation
import CoreMotion


class MotionService: NSObject{
    
    static let sharedInstance = MotionService()
    let activityManager = CMMotionActivityManager()
    var activityState: Bool = false
    var motion_state = ""
    
    override init() {
        super.init()
    }
    
    func startService(){
        if(CMMotionActivityManager.isActivityAvailable()){
            self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { data in
                if let data = data{
                    dispatch_async(dispatch_get_main_queue()) {
                        if(data.stationary == true){
                            print("Stationary")
                            self.activityState = false
                            self.motion_state = "Stationary"
                        } else if (data.walking == true){
                            print("Walking")
                            self.activityState = true
                            self.motion_state = "Walking"
                        } else if (data.running == true){
                            print("Running")
                            self.activityState = true
                            self.motion_state = "Running"
                        } else if (data.automotive == true){
                            print("Automotive")
                            self.activityState = false
                            self.motion_state = "Automotive"
                        }
                    }
                }
            })
        }
    }
}
