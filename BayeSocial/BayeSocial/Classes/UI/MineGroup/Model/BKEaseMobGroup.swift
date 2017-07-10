//
//  BKEaseMobGruop.swift
//  BayeSocial
//
//  Created by 董招兵 on 2017/2/20.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 环信群组
class BKEaseMobGroup: RLMObject {

    dynamic var groupId : String?
    dynamic var userAccount : String?
    open override class func primaryKey() -> String? {
        return "groupId"
    }
    
    
}


/// 存储环信联系人
class BKEaseMobContact: RLMObject {
    dynamic var userId : String?
    dynamic var userAccount : String?
    open override class func primaryKey() -> String? {
        return "userId"
    }
}
