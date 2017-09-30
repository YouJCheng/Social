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
        let grad = CAGradientLayer()
        grad.colors = [
            UIColor.red.cgColor, // top color
            UIColor.magenta.cgColor // bottom color
        ]
        grad.locations = [
            0.0, // start gradating at top of view
            1.0  // end gradating at bottom of view
        ]

        grad.frame = view.layer.bounds
        view.layer.insertSublayer(grad, at: 1)
        

        emailTextfield.keyboardType = .emailAddress

    }
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            print("MAIL: ID found in Keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    
    @IBAction func facebookBtnPress(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("MAIL: Unable to authenticate with FAcebook - \(String(describing: error))")
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
                print("MAIL: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("MAIL: Successfully authenticate with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completedSignIn(id: user.uid, userData: userData)
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
                        let userData = ["provider": user.providerID]
                        self.completedSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("MAIL:Unable to authenticate with Firebase using email")
                        } else {
                            print("MAIL:Succesfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completedSignIn(id: user.uid, userData: userData)

                            }
                        }
                    })
                }
            })
        }
        
    }

    func completedSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid:id, userData:userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("MAIL: Data saved to keychain\(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    
}

