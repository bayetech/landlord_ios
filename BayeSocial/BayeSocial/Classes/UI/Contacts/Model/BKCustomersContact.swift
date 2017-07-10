//
//  BKCustomersContact.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/24.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

/// 联系人信息的模型
class BKCustomersContact :  RLMObject {

    dynamic var avatar : String             = ""
    dynamic var mobile : String             = ""
    dynamic var name : String               = ""
    dynamic var uid : String                = ""
    dynamic var letters : String            = ""
    dynamic var applyReason : String        = ""
    dynamic var isFriend : Bool             = false
    dynamic var isSelectContact             = false
    dynamic var pinyin_letter : String      = ""
    dynamic var company : String            = ""
    dynamic var company_position : String   = ""
    dynamic var industry_function_items : String    = ""
    open override class func primaryKey() -> String? {
        return "uid"
    }
   
    /// 便利构造方法
    convenience init(name : String,uid : String,avatar : String) {
        self.init()
        self.name       = name
        self.uid        = uid
        self.avatar     = avatar
    }
    
    convenience init(withUser userInfo:UserInfo) {
        self.init()
        
        self.uid        = userInfo.uid;
        self.avatar     = userInfo.avatar ?? "";
        self.company    = userInfo.company ?? "";
        self.name       = userInfo.name;
        self.mobile     = userInfo.mobile ?? "";
        
    }
    
    convenience init(by json :JSON) {
        self.init()
        
        self.avatar                      = json["avatar"].stringValue 
        self.mobile                      = json["mobile"].stringValue 
        self.name                        = json["name"].stringValue
        self.uid                         = json["uid"].stringValue
        self.company                     = json["company"].stringValue
        self.company_position            = json["company_position"].stringValue
        self.pinyin_letter               = NSString.chineseTransformLetter(self.name)
        self.letters                     = NSString.transformFirstLetter(self.name)
        
        // 用户行业职能
        if let industrys : [JSON] = json["industry_function_items"].array {
            for (item) in industrys.reversed() {
                let str = item.stringValue
                self.industry_function_items.append(str)
                self.industry_function_items.append(" ")
            }
        }

        
    }
    
    /// 字典数组转模型数组
    class func customersWithJSONArray(_ jsonArray :[JSON]) -> [BKCustomersContact] {
        var array : [BKCustomersContact] = [BKCustomersContact]()
        for json in jsonArray {
            let customer = BKCustomersContact(by: json)
            array.append(customer)
        }
        return array
    }
    
    
}


/// 联系人分组的模型 分为 A B C D E ...
 class BKCustomerContactGroup : NSObject {
    
    var letter : String         = ""
    var items                   = RLMArray(objectClassName : BKCustomersContact.className())
    var userAccount : String?
    
   /// 获取联系人每个分组的 group模型 以 A B C D 区分每个 BKCustomerContactGroup 对象
   fileprivate class func getSearchResultBySearchText(contacts : [BKCustomersContact],title :String) -> BKCustomerContactGroup {
        
        let group                       = BKCustomerContactGroup()
        for contact in contacts {
            if contact.letters == title {
                group.items.add(contact)
                continue
            }
        }
        group.letter                    = title
        return group
    }
    
    /// 根据联系人列表 拼接成一个联系人按姓名分组的数组
    open class func appendFormatterData(customers : [BKCustomersContact]) -> [BKCustomerContactGroup] {
        
        var letters                     = [String]()
        for contact in customers {
            let firstLetter             = NSString.transformFirstLetter(contact.name)
            letters.append(firstLetter)
        }
        
        // 字母去重复
        letters = letters.filterTheSameElement()
        
        // 字母排序
        letters  = letters.sorted { (obj1, obj2) -> Bool in
            let latterOne       = obj1
            let latterTwo       = obj2
            let result          =  latterOne.compare(latterTwo)
            if result == .orderedAscending {
                return true
            } else if result    == .orderedSame {
                return true
            } else {
                return false
            }
        }
        
        var array               = [BKCustomerContactGroup]()
        for letter in letters {
            let group           = BKCustomerContactGroup.getSearchResultBySearchText(contacts: customers, title: letter)
            group.userAccount   = easemob_username
            array.append(group)
        }
        
        return array
    }

    
    
}

/// 管理用户人脉的集合 某个人的所有人脉列表
class BKUsersContactsList : RLMObject {
    
    dynamic var contacts = RLMArray(objectClassName: BKCustomersContact.className())
    dynamic var userAccount : String?
    open override class func primaryKey() -> String? {
        return "userAccount"
    }
    
}

