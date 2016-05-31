//
//  LocationService.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 4/27/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class LocationService: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    static let sharedInstance = LocationService()
    var duration = Variable<String>("")
    var allSeconds = 0
    var currentLocation =  Variable<CLLocation>(CLLocation())
    var oldLocation:CLLocation!
    var allLocation: [CLLocationCoordinate2D] = []

    var totalCalories = Variable<Double>(0.0)
    var totalDistance =  Variable<Int>(0)
    
    var countTimer: NSTimer? = nil
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        initService()
    }
    
    func initService(){
        self.oldLocation = nil
        self.totalCalories.value = 0.0
        self.totalDistance.value = 0
        self.duration.value = ""
        self.allSeconds = 0
        self.allLocation = []
        self.countTimer = nil
    }
    
    func startService(){
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        if(locationAuthorizationStatus == CLAuthorizationStatus.AuthorizedAlways){
            self.locationManager.pausesLocationUpdatesAutomatically = false
            self.locationManager.distanceFilter = 2.0
            if #available(iOS 9.0, *) {
                self.locationManager.allowsBackgroundLocationUpdates = true
            }
            self.locationManager.startUpdatingLocation()
            if(countTimer == nil){
                countTimer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(calcDuration), userInfo: nil, repeats: true)
                NSRunLoop.currentRunLoop().addTimer(self.countTimer!, forMode: NSRunLoopCommonModes)
            }
        }else{
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    func pauseService(){
        self.locationManager.stopUpdatingLocation()
    }
    
    func stopService(completion:(ret:Bool)->Void){
        self.locationManager.stopUpdatingLocation()
        self.countTimer?.invalidate()
        self.saveData(){
            (ret: Bool) in
            if ret {
                self.initService()
                completion(ret: true)
            }else{
                completion(ret: false)
            }
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status != CLAuthorizationStatus.AuthorizedAlways){
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last?.coordinate)
        if(locations.last?.horizontalAccuracy < 20){
            if self.oldLocation == nil {
                self.oldLocation = locations.last
            }else{
                    addAllLocation((locations.last?.coordinate)!)
                    self.currentLocation.value = (locations.last)!
                    let deltaDistance = calcDistance(self.currentLocation.value, oldLocation: self.oldLocation)
                    self.totalDistance.value += deltaDistance
                    //                var state = MotionService.sharedInstance.activityState
                    
                    //                if MotionService.sharedInstance.activityState {
                    
                    //                }
                    let secondsPerGPSArrived = calcDeltaTime(self.oldLocation, newLocation: self.currentLocation.value)
                    let deltaAltitude = calcDeltaAltitude(self.oldLocation.altitude, newAltitude: self.currentLocation.value.altitude)
                    let caloriesPerSecond = calcCalories(Double(deltaDistance), speed: self.currentLocation.value.speed, deltaAltitude: deltaAltitude)
                    self.totalCalories.value += caloriesPerSecond * secondsPerGPSArrived
                    self.oldLocation = self.currentLocation.value.copy() as! CLLocation
            }
        }
    }
    
  
    func calcDeltaAltitude(oldAltitude:Double, newAltitude:Double) -> Double{
        let dAltitude = newAltitude - oldAltitude
        return dAltitude
    }
    func calcDistance(newLocation:CLLocation, oldLocation: CLLocation)->Int{
        let distanceByMeter = newLocation.distanceFromLocation(oldLocation)
        return Int(distanceByMeter)
    }
    func calcDeltaTime(oldLocation: CLLocation, newLocation:CLLocation)->Double{
        let dTime = newLocation.timestamp.timeIntervalSince1970 - self.oldLocation.timestamp.timeIntervalSince1970
        return dTime
    }
    func calcCalories(deltaDistance: Double, speed: Double, deltaAltitude: Double)->Double{
        if (deltaDistance <= 0 || speed <= 0){
            return 0.0
        }
        let weight = 73.0
        let grade = deltaAltitude / deltaDistance
        let VO2 = 3.5 + (speed * 0.2) + (speed * 60 * grade * 0.9)
//        let METS = VO2 / 3.5
        let METS = VO2 / 4.0
        let caloriesPerSecond = (METS * weight) / (60*60)
        return caloriesPerSecond
    }
    func addAllLocation(location:CLLocationCoordinate2D){
        self.allLocation.append(location)
    }
    
    func saveData(completion:(ret: Bool)->Void){
        if(self.allSeconds < 10 || self.totalDistance.value < 100){
            completion(ret: false)
        }else{
            self.prepareUploadData(){ (res: Bool) in
                completion(ret: res)
            }
        }
    }
    
    func allLocationToAnyObject() -> AnyObject{
        var data = [[String: Double]]()
        self.allLocation.forEach({ location in
            let loc: Dictionary = ["latitude": location.latitude, "longitude": location.longitude]
            data.append(loc)
        })
        return data as AnyObject
    }
    
    func calcDuration(){
        self.allSeconds += 1
        self.duration.value = secondsToHoursMinutesSeconds(self.allSeconds)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        return   String(format: "%02d", seconds/3600) + ":"
                + String(format:"%02d", (seconds%3600)/60) + ":"
                + String(format: "%02d", (seconds % 3600) % 60)
    }
    
    func prepareUploadData(completion:(ret: Bool)->Void){
        let locations = allLocationToAnyObject()
        let runningData = [
            "total_distance": self.totalDistance.value,
            "duration": self.duration.value,
            "calories": self.totalCalories.value,
            "locations": locations
        ]
        FirebaseService.sharedInstance.saveLocationData(runningData){
            (res: Bool) in
                completion(ret:res)
        }
    }
}
