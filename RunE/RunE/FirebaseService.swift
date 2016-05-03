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
    var myRootRef:Firebase?
    var firebaseKey: String = ""
    override init() {
        super.init()
        // Create a reference to a Firebase location
        self.firebaseKey = Keys.sharedInstance.getFirebaseKey()
        startService()
    }
    func startService(){
        self.myRootRef = Firebase(url:"\(self.firebaseKey)")
    }
    func setToFirebase(str: String){
        self.myRootRef!.setValue(str)
    }
    
    func checkLogin(){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email", "public_profile"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                print(facebookResult)
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print(accessToken)
                self.myRootRef!.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData.provider)")
                            print("Logged in! \(authData.providerData["email"])")
                        }
                })
            }
        })
    }
}