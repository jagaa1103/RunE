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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.checkLogin()
    }
    
    @IBAction func logouClicked(sender: AnyObject) {
        FirebaseService.sharedInstance.logout()
    }
    
    func checkLogin(){
        FirebaseService.sharedInstance.checkAuth(){
            (ret: Bool) in
            if ret{
                print("============================")
                print("You are already logged in!!!")
                let menuView = self.storyboard?.instantiateViewControllerWithIdentifier("MenuView")
                self.presentViewController(menuView!, animated: true, completion: nil)
            }else{
                print("============================")
                print("You are not login yet!!!")
                let loginView = self.storyboard?.instantiateViewControllerWithIdentifier("LoginView")
                self.presentViewController(loginView!, animated: true, completion: nil)
            }
        }
    }
}

