import Foundation

let KScreenWidth  = UIScreen.main.bounds.size.width
let KScreenHeight = UIScreen.main.bounds.size.height

extension UIView {
   
//    /// height
//    public final var zj_height: CGFloat {
//        set(height) {
//            frame.size.height = height
//        }
//        get {
//            return bounds.size.height
//        }
//    }
    
    var left : CGFloat {
        let viewLeft = self.frame.minX;
        return viewLeft
    }
    var right : CGFloat {
        return self.frame.maxX;
    }
    var width : CGFloat {
        return self.frame.width;
    }
    var height : CGFloat {
        return self.frame.height
    }
    
    var top : CGFloat {
        return self.frame.minY
    }
    
    var bottom : CGFloat {
        return self.frame.maxY
    }
    
    var size : CGSize {
        return self.frame.size
    }
    func setX(_ x : CGFloat) {
        var rect      = self.frame;
        rect.origin.x = x;
        self.frame    = rect;
    }
    func setY(_ y : CGFloat) {
        var rect      = self.frame;
        rect.origin.y = y;
        self.frame    = rect;
    }
    func setWidth(_ width : CGFloat) {
        var rect        = self.frame;
        rect.size.width = width;
        self.frame      = rect;
    }
    
    func setHeight(_ height : CGFloat) {
        var rect         = self.frame;
        rect.size.height = height;
        self.frame       = rect;
    }
    
    /**
     从 XIB 加载一个 view
     */
    class func viewFromNib() -> UIView? {
        
        let className = self.className()?.components(separatedBy: ".").last
        
        if let nib : Any = Bundle.main.loadNibNamed(className! as String, owner: nil, options: nil)?.last {
            return nib as? UIView
        } else {
            return nil
        }
        
    }
    
    
    /**
     移除所有子视图
     */
    func removeAllSubviews() {
        while self.subviews.count > 0 {
            let view = self.subviews.last
            view?.removeFromSuperview()
        }
    }
    
    /// 设置圆角半径
    func setCornerRadius(_ value : CGFloat) {
        self.layer.cornerRadius     = value
        self.layer.masksToBounds    = true
    }
    /**
     给一个 view 添加手势事件
     */
    func addTarget(_ target : AnyObject?, action : Selector?) {
        
        if ((target == nil) || (action == nil)) {
            return
        }
        self.isUserInteractionEnabled = true;
        self.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action!))    
    }

}


extension UIButton {
    
    /**
     给按钮设置不同状态下的颜色
     */
    func setBackgroundColor(backgroundColor color: UIColor? ,forState state: UIControlState) {
    
        guard color != nil else {
            return
        }
        self.setBackgroundImage(UIImage.imageWithColor(color!), for: state)
    }
    
    /// 获取 button 所在 cell 的 indexPath
    
    func indexPath(at tableView : UITableView, forEvent event : Any) -> IndexPath? {
        
        // 获取 button 所在 cell 的indexPath
        let set = (event as! UIEvent).allTouches
        for (_ ,anyObj) in (set?.enumerated())! {
            let point = anyObj.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: point)
            if indexPath != nil {
                return indexPath!;
            }
        }
        
        return nil

    }
    
    
}

extension UILabel {
    
    /// 获取该label展示当前文字所需最小size，当没有文字时，返回宽度为0，高度为font。lineHeight的size
    public var displaySize: CGSize {
        if let text = text {
            return (text as NSString).boundingRect(with: CGSize(width: Double(MAXFLOAT), height: Double(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:font], context: nil).size
        } else {
            return CGSize(width: 0, height: font.lineHeight)
        }
    }
    
    
}

extension UITableView {
    
    func delayReload(with duration : Double) {
        self.perform(#selector(reloadData), with: nil, afterDelay: duration)
    }
    
}


