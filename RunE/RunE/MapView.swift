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
    @IBOutlet weak var motion_status_image: UIImageView!
    
    var refreshTimer:NSTimer? = nil
    var countTimer: NSTimer? = nil
    
    var allLocation = [CLLocationCoordinate2D]()
    let disposeBag = DisposeBag()
    
    
    var startDate:NSDate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.startDate = nil
        
        LocationService.sharedInstance.startService()
        MotionService.sharedInstance.startService()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        receiveNewLocation()
        durationUpdate()
        
//        countTimer = NSTimer(timeInterval: 1.0, target: self, selector: #selector(MapView.durationUpdate), userInfo: nil, repeats: true)
//        NSRunLoop.currentRunLoop().addTimer(self.countTimer!, forMode: NSRunLoopCommonModes)
        
        
        self.startDate = NSDate()
        
        showTotalDistance()
        showTotalCalories()
    }
    override func viewDidDisappear(animated: Bool) {
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
    }
    
    @IBAction func stopClicked(sender: AnyObject) {
        LocationService.sharedInstance.stopService(){ (ret: Bool) in
            if ret {
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                print("Location Data cannot saved")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func receiveNewLocation(){
        LocationService.sharedInstance.currentLocation.asObservable().subscribe(onNext: { location in
            self.allLocation.append(location.coordinate)
            self.showCurrentLocation(location.coordinate)
        })
        .addDisposableTo(disposeBag)
    }
    
    func showCurrentLocation(location:CLLocationCoordinate2D){
            updateMotionStatus()
        
            let region = MKCoordinateRegionMakeWithDistance(location, 700.0, 700.0)
            self.mapView.setRegion(region, animated: true)
        
            self.mapView.removeOverlays(self.mapView.overlays)

            let polylineLayer = MKPolyline(coordinates: &self.allLocation, count: self.allLocation.count)
            polylineLayer.title = "Your Run"
            self.mapView.addOverlay(polylineLayer)
    }
    
    func showTotalDistance(){
        LocationService.sharedInstance.totalDistance.asObservable().subscribeNext({ distance in
            if(distance > 999){
                self.distanceLabel.text = String(format: "%.2f", (Double(distance)/1000)) + "Km"
            }else{
                self.distanceLabel.text = String(distance) + "m"
            }
        })
        .addDisposableTo(disposeBag)
    }
    
    func showTotalCalories(){
        LocationService.sharedInstance.totalCalories.asObservable().subscribeNext({ calories in
//            self.caloriesLabel.text = String(format: "%.2f", calories)
            self.caloriesLabel.text = String(format: "%.0f", calories)
        })
        .addDisposableTo(disposeBag)
    }
    
    
    func updateMotionStatus(){
        if MotionService.sharedInstance.activityState{
                let image: UIImage = UIImage(named: MotionService.sharedInstance.motion_state)!
                self.motion_status_image = UIImageView(image: image)
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
    
    func durationUpdate(){
        LocationService.sharedInstance.duration.asObservable().subscribeNext({ duration in
            self.durationLabel.text = duration
        })
        .addDisposableTo(disposeBag)
        
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

