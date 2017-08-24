//
//  BKSendList.swift
//  BayeSocial
//
//  Created by 董招兵 on 2017/2/27.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

@objc enum SendListType : Int {
    case contact    = 0
    case group      = 1
}

/// 加好友和群组的发送请求
class BKSendList: RLMObject {
    
    @objc dynamic var uid : String?
    @objc dynamic var isSend : Bool = false
    @objc dynamic var userAccount : String?
    @objc dynamic var type : SendListType = .contact
    open override class func primaryKey() -> String? {
        return "uid"
    }
    
    convenience init(uid : String?,account : String?,type : SendListType = .contact,isSend : Bool) {
        self.init()
        
        self.userAccount        = account
        self.uid                = uid
        self.type               = type
        self.isSend             = isSend
        
    }
    

    
}
