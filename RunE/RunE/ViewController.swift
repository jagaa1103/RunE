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
        self.checkLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logouClicked(sender: AnyObject) {
        LoginService.sharedInstance.logout()
    }
    
    func checkLogin(){
        LoginService.sharedInstance.checkLogin(){
            (ret: Bool) in
            if ret{
                print("============================")
                print("You are already logged in!!!")
                let mainView = self.storyboard?.instantiateViewControllerWithIdentifier("MainView")
                self.presentViewController(mainView!, animated: true, completion: nil)
            }else{
                print("============================")
                print("You are not login yet!!!")
                let loginView = self.storyboard?.instantiateViewControllerWithIdentifier("LoginView")
                self.presentViewController(loginView!, animated: true, completion: nil)
            }
        }
    }
}

