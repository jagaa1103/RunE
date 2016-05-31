//
//  MenuView.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 4/27/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation
import UIKit

class MenuView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorTool().hexStringToUIColor("#FFFD00")
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
    }
    
    func logout(){
        self.dismissViewControllerAnimated(true, completion: nil)
        FirebaseService.sharedInstance.logout()
    }
    
}