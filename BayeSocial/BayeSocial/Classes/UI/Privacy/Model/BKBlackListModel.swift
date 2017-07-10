//
//  BKBlackListModel.swift
//  BayeSocial
//
//  Created by 董招兵 on 2017/2/20.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

class BKBlackListModel: RLMObject {

    dynamic var userAccount : String?
    dynamic var blackLists = RLMArray(objectClassName: BKCustomersContact.className())
    open override class func primaryKey() -> String? {
        return "userAccount"
    }
    
    
}
