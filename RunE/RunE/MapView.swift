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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    var refreshTimer:NSTimer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        self.refreshTimer =  NSTimer(timeInterval: 5.0, target: self, selector: #selector(MapView.showCurrentLocation), userInfo: nil, repeats: true)
//        NSRunLoop.currentRunLoop().addTimer(self.refreshTimer!, forMode: NSRunLoopCommonModes)
        
    }
    override func viewDidDisappear(animated: Bool) {
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
    }
    
    func showCurrentLocation(){
        if(LocationService.sharedInstance.lastPosition != nil){
            let currentLocation = LocationService.sharedInstance.getLastPosition()
            let region = MKCoordinateRegionMakeWithDistance(currentLocation, 400.0, 400.0)
            self.mapView.setRegion(region, animated: true)
            
            self.mapView.removeOverlays(self.mapView.overlays)
            var allLocation: [CLLocationCoordinate2D] = LocationService.sharedInstance.getAllPosition()
            let polylineLayer = MKPolyline(coordinates: &allLocation, count: allLocation.count)
            polylineLayer.title = "Your Run"
            self.mapView.addOverlay(polylineLayer)
            
            let distance = LocationService.sharedInstance.getDistance()
            var b_distance:String?
            if(distance > 999){
                b_distance = String(format: "%.2f", (Double(distance)/1000)) + "Km"
                
            }else{
                b_distance = String(distance) + "m"
            }
            self.distanceLabel.text = b_distance
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