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
    
    override init() {
        super.init()
    }
    
    func startService(){
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
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
                let deltaDistance = calculateDistance(self.alphaLocation!, oldLocation: self.betaLocation!)
                self.distance = self.distance + deltaDistance
                self.alphaLocation = self.betaLocation!.copy() as? CLLocation
                print("distance: \(self.distance)")
            }
            
            self.lastPosition = CLLocationCoordinate2D(latitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!)
            self.allLocation.append(self.lastPosition!)
        }
    }
    
    func getLastPosition()->CLLocationCoordinate2D{
        return self.lastPosition!
    }
    
    func getAllPosition()->[CLLocationCoordinate2D]{
        return self.allLocation
    }
    
    func calculateDistance(newLocation:CLLocation, oldLocation: CLLocation)->Int{
        let distanceByMeter = newLocation.distanceFromLocation(oldLocation)
        return Int(distanceByMeter)
    }
    
    func getDistance()->Int{
        return self.distance
    }
    
}