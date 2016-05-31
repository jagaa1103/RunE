//
//  LoginView.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 4/27/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation
import UIKit

class LoginView: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func loginButtonClicked(sender: AnyObject) {
        FirebaseService.sharedInstance.loginByFacebook(self){
            (ret: Bool) in
            if ret == true {
                self.closeView()
            }else{
                print("you cannot logged in")
                self.showAlert()
            }
        }
    }

    func closeView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Alert", message: "You cannot logged in. Please login!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}