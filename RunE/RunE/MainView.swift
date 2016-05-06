//
//  MainView.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 4/27/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation
import UIKit

class MainView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    @IBAction func startRunClicked(sender: AnyObject) {
        self.startRunning()
    }
    @IBAction func roadsClicked(sender: AnyObject) {
    }
    @IBAction func statisticsClicked(sender: AnyObject) {
    }
    @IBAction func logoutClicked(sender: AnyObject) {
        self.logout()
    }
    func startRunning(){
        let mapView = self.storyboard?.instantiateViewControllerWithIdentifier("MapView")
        self.presentViewController(mapView!, animated: true, completion: nil)
        LocationService.sharedInstance.startService()
        MotionService.sharedInstance.startService()
    }
    
    func logout(){
        self.dismissViewControllerAnimated(true, completion: nil)
        LoginService.sharedInstance.logout()
    }
    
}