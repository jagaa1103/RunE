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
    var lastPosition: CLLocationCoordinate2D? = nil
    var allLocation = [CLLocationCoordinate2D]()
    var alphaLocation: CLLocation? = nil
    var betaLocation: CLLocation? = nil
    var distance = 0
    var speedInMinutes:Double = 0.0
    var totalCalories:Double = 0.0
    
    var mapView:MapView? = nil
    
    override init() {
        super.init()
        
    }
    
    func initService(){
        self.lastPosition = nil
        self.allLocation = [CLLocationCoordinate2D]()
        self.alphaLocation = nil
        self.betaLocation = nil
        self.distance = 0
        self.speedInMinutes = 0.0
        self.totalCalories = 0.0
    }
    
    func startService(view: MapView){
        self.mapView = view
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func pauseService(){
        self.locationManager.stopUpdatingLocation()
    }
    
    func stopService(){
        self.locationManager.stopUpdatingLocation()
        self.initService()
    }
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.AuthorizedAlways){
            if #available(iOS 9.0, *) {
                self.locationManager.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
            }
            self.locationManager.pausesLocationUpdatesAutomatically = false
            self.locationManager.distanceFilter = 2.0
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(locations.last?.horizontalAccuracy < 20){
            if self.alphaLocation == nil {
                self.alphaLocation = locations.last
            }else{
                self.betaLocation = locations.last
                self.speedInMinutes = (locations.last?.speed)! * 60
                let deltaDistance = calculateDistance(self.alphaLocation!, oldLocation: self.betaLocation!)
                
//                var state = MotionService.sharedInstance.activityState 
                
                if MotionService.sharedInstance.activityState {
                    self.distance = self.distance + deltaDistance
                    print("distance: \(self.distance)")
                    self.allLocation.append(self.lastPosition!)
                }
                
                let secondsPerGPSArrived = (self.betaLocation?.timestamp.timeIntervalSince1970)! - (self.alphaLocation?.timestamp.timeIntervalSince1970)!
                let deltaAltitude = (self.betaLocation?.altitude)! - (self.alphaLocation?.altitude)!
                let caloriesPerSecond = calculateCalories(Double(deltaDistance), speed: self.speedInMinutes, deltaAltitude: deltaAltitude)
                self.totalCalories += caloriesPerSecond * secondsPerGPSArrived
                    
                self.alphaLocation = self.betaLocation!.copy() as? CLLocation
            }
            self.lastPosition = CLLocationCoordinate2D(latitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!)
            
        }
    }
    
    func getLastPosition()->CLLocationCoordinate2D{
        return self.lastPosition!
    }
    
    func getAllPosition()->[CLLocationCoordinate2D]{
        return self.allLocation
    }
    
    func getDistance()->Int{
        return self.distance
    }
    
    func getTotalCalories()->Double{
        return self.totalCalories
    }
    
    func calculateDistance(newLocation:CLLocation, oldLocation: CLLocation)->Int{
        let distanceByMeter = newLocation.distanceFromLocation(oldLocation)
        return Int(distanceByMeter)
    }
    func calculateCalories(deltaDistance: Double, speed: Double, deltaAltitude: Double)->Double{
        let weight = 73.0
        let grade = deltaAltitude / deltaDistance
        let VO2 = 3.5 + (speed * 0.2) + (speed * grade * 0.9)
//        let METS = VO2 / 3.5
        let METS = VO2 / 4.0
        let caloriesPerSecond = (METS * weight) / (60*60)
        return caloriesPerSecond
    }
}