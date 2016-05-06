//
//  LoginService.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 4/27/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit



class LoginService: NSObject{
    
    static let sharedInstance = LoginService()
    var user_auth:String? = nil
    var rootRef: Firebase? = nil
    
    override init() {
        super.init()
        setRootRef()
    }
    
    func setRootRef(){
        if(self.rootRef == nil){
            self.rootRef = FirebaseService.sharedInstance.getFirebaseRef()
        }
    }
    
    func checkLogin(completion: (ret:Bool)->Void){
        self.rootRef!.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print("user is logged in")
                self.user_auth = "\(authData)"
                completion(ret: true)
            } else {
                // No user is signed in
                print("user is not login  yet")
                completion(ret: false)
            }
        })
    }
    
    func loginByFacebook(completion:(ret:String)->Void){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email", "public_profile"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                completion(ret: "failed")
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
                completion(ret: "cancelled")
            } else {
                print(facebookResult)
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print(accessToken)
                self.rootRef!.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData.provider)")
                            print("Logged in! \(authData.providerData["email"])")
                            let newUser = [
                                "provider": authData.provider,
                                "displayName": authData.providerData["displayName"] as? String,
                                "email": authData.providerData["email"] as? String
                            ]
                            self.saveUserData(authData.uid, userInfo: newUser)
                            completion(ret: "loggedIn")
                        }
                })
            }
        })
    }
    
    func logout(){
        self.rootRef!.unauth()
    }
    
    func saveUserData(uid:AnyObject, userInfo:AnyObject){
        self.rootRef!.childByAppendingPath("users").childByAppendingPath(uid as! String).setValue(userInfo)
    }
    
    func getUserInfo()->String{
        return self.user_auth!
    }
}