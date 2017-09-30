//
//  DataService.swift
//  Social
//
//  Created by mail on 2017/2/16.
//  Copyright © 2017年 YuChienCheng. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    // DB reference
    private var _REF_BASE = DB_BASE
    private var _REF_POST = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    
    // Storage reference
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    private var _REF_USER_IMAGES = STORAGE_BASE.child("user-images")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POST: FIRDatabaseReference {
        return _REF_POST
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }

    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMAGES
    }
    
    var REF_USER_IMAGES: FIRStorageReference {
        return _REF_USER_IMAGES
    }
    
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        
        REF_USERS.child(uid).updateChildValues(userData)
    
    }
    
    
}
