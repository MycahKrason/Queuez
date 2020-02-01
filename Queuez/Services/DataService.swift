//
//  DataService.swift
//  Queuez
//
//  Created by Mycah on 8/8/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import Firebase

let DB_BASE = Database.database().reference()

class DataService{
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    
    //Reference for Users and Vendors
    private var _REF_USERS = DB_BASE.child("Users")
    private var _REF_QUEUES = DB_BASE.child("Queuez")
    private var _REF_USERINFO = DB_BASE.child("UserInfo")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference{
        return _REF_USERS
    }
    
    var REF_USERINFO: DatabaseReference{
        return _REF_USERINFO
    }
    
    var REF_QUEUES : DatabaseReference{
        return _REF_QUEUES
    }
    
    func createFBDBUser(uid: String, userData: Dictionary<String, Any>){
        
        REF_USERINFO.child(uid).updateChildValues(userData)
        
        REF_USERS.child(uid).updateChildValues(["UserCreated" : true])
        
    }
}

