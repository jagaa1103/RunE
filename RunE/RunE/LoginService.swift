//
//  LoginService.swift
//  RunE
//
//  Created by Enkhjargal Gansukh on 4/27/16.
//  Copyright © 2016 Enkhjargal Gansukh. All rights reserved.
//

import Foundation

class LoginService: NSObject{

    static let sharedInstance = LoginService()
    
    override init() {
        super.init()
    }
    
    func checkLogin(){
        FirebaseService.sharedInstance.checkLogin()
    }
    
}