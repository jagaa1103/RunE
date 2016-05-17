//
//  MapView.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 4/27/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class MapView: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    var refreshTimer:NSTimer? = nil
    var countTimer: NSTimer? = nil
    var allLocation = [CLLocationCoordinate2D]()
    var allDataLocation = [[String: Double]]()
    
    var total_distance:Int = 0
    var total_calories = 0.0
    
    var startDate:NSDate?
    
    @IBAction func stopClicked(sender: AnyObject) {
        LocationService.sharedInstance.stopService()
        self.saveData(){
            (ret: Bool) in
            if ret {
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                print("Location Data cannot saved")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.startDate = nil
        
        LocationService.sharedInstance.startService(self)
        MotionService.sharedInstance.startService()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshTimer =  NSTimer(timeInterval: 5.0, target: self, selector: #selector(MapView.showCurrentLocation), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.refreshTimer!, forMode: NSRunLoopCommonModes)
        
        countTimer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(MapView.durationUpdate), userInfo: nil, repeats: true)
        
        NSRunLoop.currentRunLoop().addTimer(self.countTimer!, forMode: NSRunLoopCommonModes)
        
        self.startDate = NSDate()
    }
    override func viewDidDisappear(animated: Bool) {
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
    }
    
    func showCurrentLocation(){
        if(LocationService.sharedInstance.lastPosition != nil){
            let currentLocation = LocationService.sharedInstance.getLastPosition()
            
            let cur_location:Dictionary = ["lat": currentLocation.latitude, "lon": currentLocation.longitude]
            self.allDataLocation.append(cur_location)
            
            let region = MKCoordinateRegionMakeWithDistance(currentLocation, 400.0, 400.0)
            self.mapView.setRegion(region, animated: true)
            
            self.mapView.removeOverlays(self.mapView.overlays)
            self.allLocation = LocationService.sharedInstance.getAllPosition()
            let polylineLayer = MKPolyline(coordinates: &allLocation, count: allLocation.count)
            polylineLayer.title = "Your Run"
            self.mapView.addOverlay(polylineLayer)
            
            self.total_distance = LocationService.sharedInstance.getDistance()
            self.total_calories = LocationService.sharedInstance.getTotalCalories()
            
            if(self.total_distance > 999){
                self.distanceLabel.text = String(format: "%.2f", (Double(self.total_distance)/1000)) + "Km"
            }else{
                self.distanceLabel.text = String(self.total_distance) + "m"
            }
            self.caloriesLabel.text = String(format: "%.2f", self.total_calories)
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let gradientColors = [UIColor.greenColor(), UIColor.yellowColor(), UIColor.redColor()]
        /* Initialise a JLTGradientPathRenderer with the colors */
        let polylineRenderer = JLTGradientPathRenderer(polyline: overlay as! MKPolyline, colors: gradientColors)
        polylineRenderer.border = true
        
        if overlay is MKPolyline {
            polylineRenderer.lineWidth = 7
            return polylineRenderer
        }
        return polylineRenderer
    }
    
    func saveData(completion:(ret: Bool)->Void){
        if(self.total_distance < 10){
            completion(ret:true)
        }
        LocationService.sharedInstance.stopService()
        let userInfo = LoginService.sharedInstance.getUserInfo()
        
        let duration = NSDate().offsetFrom(self.startDate!)
        
        let running_info = ["total_distance": self.total_distance, "duration": duration, "calories": self.total_calories, "locations": self.allDataLocation as AnyObject]
        
        FirebaseService.sharedInstance.saveLocationData(userInfo, running_info: running_info){
            (ret: Bool) in
            if ret {
                completion(ret:true)
            }else{
                completion(ret:false)
            }
        }
    }
    
    var hour = 0
    var minute = 0
    var second = 0
    func durationUpdate(){
        if(self.minute > 59){
            self.hour += 1
            self.minute = 0
        }
        if(self.second > 59){
            self.second = 0
            self.minute += 1
        }else{
            self.second += 1
        }
        self.durationLabel.text = "\(String(format: "%02d", self.hour)):\(String(format: "%02d", self.minute)):\(String(format: "%02d", self.second))"
    }
}

class mapAnnotation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}

class DataSet{
    let latitude: Double? = nil
    let longitude: Double? = nil
}

extension NSDate {
    func offsetFrom(date:NSDate) -> String {
        
        let dayHourMinuteSecond: NSCalendarUnit = [.Day, .Hour, .Minute, .Second]
        let difference = NSCalendar.currentCalendar().components(dayHourMinuteSecond, fromDate: date, toDate: self, options: [])
        
        let seconds = "\(difference.second)s"
        let minutes = "\(difference.minute)m" + " " + seconds
        let hours = "\(difference.hour)h" + " " + minutes
        let days = "\(difference.day)d" + " " + hours
        
        if difference.day    > 0 { return days }
        if difference.hour   > 0 { return hours }
        if difference.minute > 0 { return minutes }
        if difference.second > 0 { return seconds }
        return ""
    }
    
}

