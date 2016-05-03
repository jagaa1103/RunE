//
//  ViewController.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 4/27/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FirebaseService.sharedInstance.setToFirebase("hi Firebase")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startRunningClicked(sender: AnyObject) {
        startRunning()
    }
    @IBAction func checkLoginClicked(sender: AnyObject) {
        LoginService.sharedInstance.checkLogin()
    }
    
    func startRunning(){
        let mapView = self.storyboard?.instantiateViewControllerWithIdentifier("MapView")
        self.presentViewController(mapView!, animated: true, completion: nil)
        LocationService.sharedInstance.startService()
        MotionService.sharedInstance.startService()
    }
}

