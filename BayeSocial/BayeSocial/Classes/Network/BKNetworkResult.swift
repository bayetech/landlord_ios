//
//  BKNetworkResult.swift
//  Baye
//
//  Created by dzb on 16/7/26.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

/// 网络请求结果处理
class BKNetworkResult : NSObject {

    var error : NSError = NSError(domain: "未知错误", code: 505, userInfo: nil) {
        didSet {
            errorMsg = error.localizedDescription
        }
    }
    var errorMsg : String           = "未知错误"
    var value : [String : JSON]     = [String :JSON]()
    var statusCode : Int = 200
    var data : Any?
    
    
}
