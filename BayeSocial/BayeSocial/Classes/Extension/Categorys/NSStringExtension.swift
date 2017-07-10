//
//  NSStringExtension.swift
//  Baye
//
//  Created by dzb on 16/8/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import Foundation
import Spring

struct StringRange {
    
    var location : Int
    var length   : Int
    init(location : Int,length : Int) {
        self.location   = location
        self.length     = length
    }
    
}

extension String {
    
    /// 截取字符串到某个位置
    func subString(to index :Int) -> String {
        if index > self.characters.count {
            return ""
        }
        let text : String                       = self
        let startIndex : String.Index           = text.startIndex
        let subIndex : String.Index             = text.index(startIndex, offsetBy: index)
        return text.substring(to: subIndex)
    }
 
    /// 从某个位置开始截取字符串
    func subString(from index : Int) -> String {
        if index > self.characters.count {
            return ""
        }
        let text : String                       = self
        let startIndex : String.Index           = text.startIndex
        let subIndex : String.Index             = text.index(startIndex, offsetBy: index)
        return text.substring(from: subIndex)
    }
    
    /// 从某个范围截取字符串 比如 2这个位置 截取 3个长度
    func subString(from range : StringRange) -> String {
        
        let text : String                       = self
        
        if range.location > text.length {
            return ""
        }
        
        if range.location + range.length > text.length {
            return ""
        }
        
        let startIndex                  = text.index(text.startIndex, offsetBy: range.location)        
        let endIndex                    = text.index(startIndex, offsetBy: range.length)
        let range                       = Range<String.Index>(startIndex..<endIndex)
        
        return text.substring(with: range)
        
    }
    
    /// 版本号转成整型
    func versionStringToInteger() -> Int {
        let version = replacingOccurrences(of: ".", with: "")
        return version.intValue
    }
    
    var length : Int {
        get {
            return self.characters.count
        }
    }
    
    func stringIsBoolValue() -> Bool {
        switch self {
        case "true" , "1":
            return true
        default:
            return false
        }
    }
    
    public var doubleValue: Double {
        let str = self as NSString
        return str.doubleValue
    }
    
    public var intValue : Int {
        let str = self as NSString
        return str.integerValue
    }
    
    public var floatValue : Float {
        let str = self as NSString
        return str.floatValue
    }
    
    /// 检查字符串是否是0-9的数字
    func isNumberValue() ->Bool {
        let number                      = "^[0-9]*$"
        let regextestmobile             = NSPredicate(format:"SELF MATCHES %@",number)
        let isNumber                    = regextestmobile.evaluate(with: (self))
        return isNumber
    }
    
    func getTextSize(_ font : UIFont , restrictWidth width : CGFloat) -> CGSize {
        let dict            = [NSFontAttributeName : font]
        let string          = self as NSString
        let size            = string.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: dict, context: nil).size
        return size
    }
    
    /// json 字符串转成 Array

    func  arrayValue() -> Array<Any> {
        let jsonObject = jsonToData()
        if let jsonArray = jsonObject  {
            return (jsonArray as! Array)
        } else {
            return Array()
        }
    }
    
    /// json 字符串转成 NSData
    func jsonToData() -> Any? {
        
        let data            = self.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let jsonObject      = try? JSONSerialization.jsonObject(with:data!, options: .allowFragments)
        
        return jsonObject
    }
    
    /// json 字符串转成 Dictionary
    func dictionaryValue() -> Dictionary<String, Any> {

        let jsonObject          = jsonToData()
        if let jsonArray        = jsonObject  {
            return (jsonArray as! Dictionary)
        } else {
            return Dictionary()
        }
        
    }
    
    
    
}
