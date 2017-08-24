
import HandyJSON


/**
 根据一个类找到这个类字符串
 */
public func stringFromClass(_ aClass : AnyClass?) -> String? {
    
    if aClass == nil {
        return nil
    }
    
    let className = NSStringFromClass(aClass!)
    return className
}

/**
 从一个字符串生成一个类
 */
public func classFromString(_ className : String?) -> AnyClass? {
    
    if className == nil {
        return nil
    }
    
    guard let name =  Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else
    {
        NJLog("获取命名空间失败")
        return nil
    }
    
    let cls: AnyClass? = NSClassFromString(name + "." + className!)
    
    return cls
}

extension NSObject {
    
    class func instance() -> Self {
        return self.init()
    }
    /**
     获取类名 命名空间.加文件名 如 Baye.Home
     */
    public class func className() -> String? {
        
        let className = stringFromClass(self)
        guard className != nil else {
            return nil
        }
        return className
    }
   

    /// 一个类对象的类型 AnyClass
    var classType : AnyClass {
        get {
            return self.classForCoder
        }
    }
   
   
}

extension Array {
    
    func filterTheSameElement() -> Array {
        let set = NSMutableSet(array: self)
        
        return set.allObjects as! Array<Element>
    }
    
    
}

// MARK: - AutoLayout 约束更新类
extension NSLayoutConstraint {
    
    /**
     更新约束
     */
    func updateConstraint(_ value : CGFloat)  {
        self.constant = CYLayoutConstraintValue(value)
    }
    
}

extension  DispatchQueue {
    
    /// 延时调用一段代码
    public func delay(deadline: Double, execute: DispatchWorkItem) {
        self.asyncAfter(deadline: DispatchTime.now() + deadline, execute: execute)
    }
    
    /// 主线程异步执行
    public class func mainAsync(_ main : @escaping () -> Void ) {
        DispatchQueue.main.async {
            main()
        }
    }
    
    /// 异步线程
    public class func globalAsync(_ global : @escaping () -> Void) {
        DispatchQueue.global().async {
            global()
        }
    }
    
    /// 执行耗时操作完毕后回到主线程
    public class func startAsync(_ global : @escaping () -> Void,main : @escaping () -> Void) {
        DispatchQueue.global().async {
            global()
            DispatchQueue.main.async {
                main()
            }
        }
    }
    
    
}

extension OperationQueue {
    
    public class func mainAsync(_ main : @escaping () -> Void) {
        OperationQueue.main.addOperation {
            main()
        }
    }
    
}

extension Dictionary {
    
    var jsonString : String {
        get {
            if let data = try? JSONSerialization.data(withJSONObject: (self), options: []),
                let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                return string
            }
            return ""
        }
    }
    
}

extension Array {
    
    var jsonString : String {
        get {
            if let data = try? JSONSerialization.data(withJSONObject: (self), options: []),
                let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
                return string
            }
            return ""
        }
    }
}

extension Data {
    
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
        let jsonObject  = try? JSONSerialization.jsonObject(with:self, options: .allowFragments)
        return jsonObject
    }
    
    /// json 字符串转成 Dictionary
    func dictionaryValue() -> Dictionary<String, Any> {
        
        let jsonObject      = jsonToData()
        if let jsonArray    = jsonObject  {
            return (jsonArray as! Dictionary)
        } else {
            return Dictionary()
        }
        
    }

    
}

extension JSONDeserializer {
    
     /// 将Dictionary 类型转成 model
     public static func deserializeFromDictionary(_ dictionary :[String :Any]?) -> T? {
        let jsonString = JSONSerializer.serializeToJSON(object: dictionary)
        return deserializeFrom(json: jsonString, designatedPath: nil)
    }

}


extension Date {
    
    static func dateFormatterTimeInterval(_ timeInterval : Double,tiemFormatter : String) -> String {
    
        let date                = NSDate(timeIntervalSince1970: timeInterval)
        let formatter           = DateFormatter()
        formatter.dateFormat    = tiemFormatter
        return  formatter.string(from: date as Date)
        
    }
    
    static func  stringWithCurrentTimeInterval(_ timeInterval : Int) -> String {
        
        var mins : Int                  = 0
        var hours : Int                 = 0
        var seconds : Int               = (timeInterval) % 60
        // 小于1分钟
        if timeInterval < 60 {
            seconds             = timeInterval
            return "\(seconds)秒"
        } else if timeInterval>=60 && timeInterval<3600 {
            // 小于1小时
            mins                = Int(timeInterval/60)
            return String(format: "%@%@", (mins == 0 ? "" : "\(mins)分"),( seconds == 0 ? "" : "\(seconds)秒"))
        } else if timeInterval>=3600 {
            // 超过1小时
            hours               =  timeInterval/3600
            mins                =  timeInterval%3600/60
            return String(format: "%@%@%@", (hours == 0 ? "" : "\(hours)小时"), (mins == 0 ? "" : "\(mins)分"),( seconds == 0 ? "" : "\(seconds)秒"))
        }
        return ""
    }
    
}



extension NotificationCenter {
    
    class func bk_postNotication(_ name : String) {
        bk_postNotication(name, obj: nil, info: nil)
    }
    
    class func bk_postNotication(_ name : String ,object : Any?) {
        bk_postNotication(name, obj: object, info: nil)
    }
    
    class func bk_postNotication(_ name : String,obj : Any?,info : [String : Any]?) {
        
        let noticeCenter        = NotificationCenter.default
        noticeCenter.post(name:  NSNotification.Name(rawValue: name), object: obj, userInfo: info)
    }
    
    class func bk_addObserver(_ observer: Any, selector aSelector: Selector, name aName: String, object anObject: Any?) {
        
        let noticeCenter = NotificationCenter.default
        noticeCenter.addObserver(observer, selector: aSelector, name: NSNotification.Name(rawValue: aName), object: anObject)
        
    }
    
}




