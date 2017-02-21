//
//  FeedVC.swift
//  Social
//
//  Created by mail on 2017/2/15.
//  Copyright © 2017年 YuChienCheng. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageAdd: CircleView!
   
    @IBOutlet weak var captionField: FancyField!
    
    
    
    var posts = [Post]()
   
    var imagePicker:UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POST.observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
                
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post)
            }
            return cell
        } else {
            return PostCell()
        }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("MAIL: A valid image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutPress(_ sender: AnyObject) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("MAIL: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        
    }
    @IBAction func addImagePress(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func postBtnPress(_ sender: AnyObject) {
        guard let caption = captionField.text, caption != "" else {
            print("MAIL: Caption must be enterd")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("MAIL: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jepg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata:metadata) { (metadata, error) in
                if error != nil {
                    print ("MAIL: Unable to upload to Firebase storage")
                } else {
                    print ("MAIL: Able to upload to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                    self.postToFireBase(imageUrl: url)
                    }
                }
            }
            
        }
        
    }
    
    func postToFireBase(imageUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text! as AnyObject ,
            "imageUrl": imageUrl as AnyObject,
            "likes": 0 as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_POST.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        tableView.reloadData()
        
    }

}
