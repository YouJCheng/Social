//
//  ViewController.swift
//  Social
//
//  Created by mail on 2017/2/14.
//  Copyright © 2017年 YuChienCheng. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailTextfield: FancyField!
    @IBOutlet weak var passwordTextField: FancyField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            print("MAIL: ID found in Keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func facebookBtnPress(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("MAIL: Unable to authenticate with FAcebook - \(error)")
            } else if result?.isCancelled == true {
                print("MAIL: User cancel Facebook authentication")
            } else {
                print("MAIL: Successfully authenticated with facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ credential:FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("MAIL: Unable to authenticate with Firebase - \(error)")
            } else {
                print("MAIL: Successfully authenticate with Firebase")
                if let user = user {
                    KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
                }
            }
        })
    }

    @IBAction func signInBtnPress(_ sender: Any) {
        
        if let email = emailTextfield.text, let pwd = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("MAIL: Email user authenticated with firebase")
                    if let user = user {
                        self.completedSignIn(id: user.uid)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("MAIL:Unable to authenticate with Firebase using email")
                        } else {
                            print("MAIL:Succesfully authenticated with Firebase")
                            if let user = user {
                                self.completedSignIn(id: user.uid)
                            }
                        }
                    })
                }
            })
        }
        
    }
    func completedSignIn(id: String) {
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("MAIL: Data saved to keychain\(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    
}

