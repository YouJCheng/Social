//
//  PostCell.swift
//  Social
//
//  Created by mail on 2017/2/16.
//  Copyright © 2017年 YuChienCheng. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    
    var post: Post!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(post:Post) {
        self.post = post
        self.caption.text = post.caption
        self.likeLbl.text = "\(post.likes)"
    }
  
    
    

}
