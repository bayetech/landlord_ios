//
//  BKRedPacketDetailModel.swift
//  BayeSocial
//
//  Created by dzb on 2017/1/11.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import HandyJSON

class BKRedPacketDetailModel : HandyJSON {

    var owner_customer_name : String?
    var owner_customer_avatar : String = ""
    var uid : String?
    var coin : Double                   = 0.0
    var opened_coin : Double            = 1.0
    var red_packets_count : Int         = 1
    var opened_red_packets_count : Int  = 0
    var message : String                = "爷，给您请安啦！"
    var expired_at : Bool               = false
    var max_coin_customer_uid : String  = ""
    var last_opened_at : Double         = 0
    var owner_customer_uid : String     = ""
    var category : String               = ""
    var created_at : Double             = 0
    var red_packets :  [BKRedpacketSubjects]?
    
    required init() {
        
    }
    
  
}

struct BKRedpacketSubjects : HandyJSON {
    
    var customer_name : String?
    var opened_at : TimeInterval = 0
    var coin : Double = 1
    var customer_avatar : String = ""
    var customer_uid : String?
    
}
