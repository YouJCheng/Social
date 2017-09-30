//
//  Constants.swift
//  Social
//
//  Created by mail on 2017/2/15.
//  Copyright © 2017年 YuChienCheng. All rights reserved.
//

import UIKit

let SHADOW_GRAY:CGFloat = 120.0/255.0
let KEY_UID = "uid"

enum InputError: String{
    case emptyField = "電子郵件或密碼有一欄為空值"
    case emailIsNotFormat = "電子郵件格式不正確"
    case passwordIsNotFormat = "密碼不能少於6個字元"
}
