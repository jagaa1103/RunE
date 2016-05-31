//
//  FirebaseService.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 5/3/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class FirebaseService: NSObject{
    static let sharedInstance = FirebaseService()
    var rootRef = FIRDatabase.database().reference()
    var auth = FIRAuth.auth()
    
    var firebaseKey: String = ""
    override init() {
        super.init()
    }
    
    func saveLocationData(running_info: AnyObject, completion:(ret:Bool)->Void){
        let locationRef = self.rootRef.child("location_data").child(String(self.auth!.currentUser!.uid)).child(getCurrentTime())
        locationRef.setValue(running_info, withCompletionBlock: {
            (err: NSError?, ref: FIRDatabaseReference) in
                if (err != nil){
                    print("Data could not be saved.")
                    completion(ret:false)
                }else{
                    print("Data saved successfully!")
                    completion(ret:true)
                }
        })
    }
    
    func checkAuth(completion:(ret:Bool)->Void){
        if let currentUser = self.auth!.currentUser {
            print("user is logged in")
            print(currentUser)
            completion(ret:true)
        }else{
            print("user is not logged in")
            completion(ret:false)
        }
    }
    
    func loginByFacebook(view: UIViewController, completion:(ret:Bool)->Void){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email", "public_profile"], fromViewController: view, handler: {
            (result, error) -> Void in
            if error != nil {
                completion(ret: false)
                print("Facebook login failed. Error \(error)")
            } else if result.isCancelled {
                print("Facebook login was cancelled.")
                completion(ret: false)
            } else {
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                self.firebaselogin(credential){
                    (ret: Bool) in
                    if(ret == true){
                        completion(ret: true)
                    }else{
                        completion(ret: false)
                    }
                }
            }

        })
    }
    
    func firebaselogin(credential: FIRAuthCredential, completion:(ret: Bool)->Void){
        if let user = self.auth!.currentUser {
            user.linkWithCredential(credential) { (user, error) in
                if (error != nil){
                    print("cannot login credential")
                    completion(ret: false)
                }else{
                    print("login credential")
                    completion(ret: true)
                }
            }
        } else {
            self.auth!.signInWithCredential(credential) { (user, error) in
                if (error != nil){
                    print("cannot login credential")
                    completion(ret: false)
                }else{
                    print("login credential")
                    completion(ret: true)
                }
            }
        }
    }
    
    func logout(){
        do {
            try self.auth!.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func getCurrentTime()->String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        let date = NSDate()
        var currentDate = dateFormatter.stringFromDate(date)
        let calendar = NSCalendar.currentCalendar()
        let hour = calendar.component(NSCalendarUnit.Hour, fromDate: date)
        let minute = calendar.component(NSCalendarUnit.Minute, fromDate: date)
        let second = calendar.component(NSCalendarUnit.Minute, fromDate: date)
        currentDate = "\(hour):\(minute):\(second)," + currentDate
        return currentDate
    }
}