//
//  Userinfo.swift
//  Baye
//
//  Created by 张少康 on 15/8/14.
//  Copyright (c) 2015年 Bayekeji. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserInfo: RLMObject {

    @objc dynamic var detail_address : String         = ""
    @objc dynamic var province : String               = ""
    @objc dynamic var company_position : String       = ""
    @objc dynamic var city : String                   = ""
    @objc dynamic var county : String                 = ""
    @objc dynamic var mobile : String?
    @objc dynamic var avatar : String?
    @objc dynamic var name: String                    = ""
    @objc dynamic var company: String?
    @objc dynamic var email: String?
    @objc dynamic var verifyCode: String?
    @objc dynamic var gender: String?
    @objc dynamic var coin_balance: String            = "0"
    @objc dynamic var user_level: String?
    @objc dynamic var level : String                  = "游客"
    @objc dynamic var uid : String                    = ""
    @objc dynamic var baye_converge_position : String = ""
    @objc dynamic var baye_level : String             = ""
    @objc dynamic var industry_function_items : String = ""
    @objc dynamic var baye_converge_name : String?
    @objc dynamic var recent_hub_images : Data?
    @objc dynamic var namecard_visible_scope : String?
    @objc dynamic var top_customer_friends            = RLMArray(objectClassName: BKCustomersContact.className())
    @objc dynamic var joined_chat_groups              = RLMArray(objectClassName: BKChatGroupModel.className())
    
    @objc dynamic var mobile_visible_scope : String?
    @objc dynamic var hub_background_image : String  = ""
    @objc dynamic var userAccount : String?
    
    open override class func primaryKey() -> String? {
        return "userAccount"
    }

    convenience init(with json : [String : JSON]) {
        self.init()
        
        self.detail_address                             = json["detail_address"]?.stringValue ?? ""
        self.province                                   = json["province"]?.stringValue ?? ""
        self.company_position                           = json["company_position"]?.stringValue ?? ""
        self.city                                       = json["city"]?.stringValue ?? ""
        self.county                                     = json["county"]?.stringValue ?? ""
        self.mobile                                     = json["mobile"]?.stringValue ?? ""
        self.avatar                                     = json["avatar"]?.stringValue ?? ""
        self.name                                       = json["name"]?.stringValue ?? ""
        self.company                                    = json["company"]?.stringValue ?? ""

        self.email                                      = json["email"]?.stringValue ?? ""
        self.verifyCode                                 = json["verifyCode"]?.stringValue ?? ""
        self.gender                                     = json["gender"]?.stringValue ?? ""
        self.coin_balance                               = json["coin_balance"]?.stringValue ?? ""
        self.user_level                                 = json["user_level"]?.stringValue ?? ""
        self.level                                      = json["level"]?.stringValue ?? ""
        self.uid                                        = json["uid"]?.stringValue ?? ""
        self.baye_converge_position                     = json["baye_converge_position"]?.stringValue ?? ""
        self.baye_level                                 = json["baye_level"]?.stringValue ?? ""
        self.baye_converge_name                         = json["baye_converge_name"]?.stringValue ?? ""
        
        // 用户行业职能
        if let industrys : [JSON] = json["industry_function_items"]?.arrayValue {
            for (item) in industrys.reversed() {
                let str = item.stringValue
                self.industry_function_items.append(str)
                self.industry_function_items.append(" ")
            }
            
        }
    
        self.namecard_visible_scope = json["namecard_visible_scope"]?.stringValue ?? ""
        self.hub_background_image   = json["hub_background_image"]?.stringValue ?? ""
        if let hub_images = json["recent_hub_images"]?.arrayValue {
            var array : [String] = [String]()
            for item in hub_images.reversed() {
                let url = item["url"].stringValue
                array.append(url)
            }
            self.recent_hub_images =  try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
        }
        
        // 用户人脉列表
        if let top_customer_friends = json["top_customer_friends"]?.arrayValue {

            for item in top_customer_friends.reversed() {
                
                let contact         = BKCustomersContact(by: item)
                contact.isFriend    = BKRealmManager.shared().customerUserIsFriendOrder(by: contact.uid)
                self.top_customer_friends.add(contact)
            
            }
            
        }
        
        // 用户加入的群组
        if let joined_chat_groups = json["joined_chat_groups"]?.arrayValue {
            for item in joined_chat_groups.reversed() {
                let group       = BKChatGroupModel(by: item)
                self.joined_chat_groups.add(group)
            }
        }
        
        // 用户的登录账户        
        
        self.userAccount           = self.uid

    }
    
    deinit {
        
    }
    
    
}
