//
//  BKAuthorizationToken.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

/// 用户授权信息的模型
class BKAuthorizationToken: RLMObject {

    @objc class func shared() ->  BKAuthorizationToken {
        let  authorization = BKRealmManager.shared().readLoginAuthorization()
        return authorization ?? BKAuthorizationToken()
    }
    @objc dynamic var session_id : String?
    @objc dynamic var easemob_username : String = ""
    @objc dynamic var easemob_password : String = ""
    @objc dynamic var expire_at : Int = 0
    @objc dynamic var userAccount : String = ""
    open override class func primaryKey() -> String? {
        return "userAccount"
    }

    convenience init(by json : [String : JSON]) {
        self.init()        
        self.session_id         = json["session_id"]?.stringValue
        self.easemob_username   = json["easemob_username"]?.stringValue ?? ""
        self.easemob_password   = json["easemob_password"]?.stringValue ?? ""
        self.expire_at          = json["expire_at"]?.intValue ?? 0
    }
}
