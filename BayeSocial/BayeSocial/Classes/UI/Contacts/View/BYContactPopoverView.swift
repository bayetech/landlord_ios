//
//  BYContactPopoverView.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

enum ContactAddBtnType : Int {
    case createGroup    = 0
    case addFriend      = 1
    case scanQRCode     = 2
}

protocol BYContactPopoverViewDelegate : NSObjectProtocol {
    func didSelectButton(_ popoverView :BYContactPopoverView ,type : ContactAddBtnType)
    func didDismissPopoverView(_ popoverView :BYContactPopoverView)
}

/// 添加好友 创建群聊的 popoverview
class BYContactPopoverView: UIView {

    weak var delegate : BYContactPopoverViewDelegate?
    @IBOutlet weak var popoverTopViewRight: NSLayoutConstraint!
    @IBOutlet weak var popoverViewRight: NSLayoutConstraint!
    @IBOutlet weak var popoverViewTop: NSLayoutConstraint!
    @IBOutlet weak var popoverViewHeight: NSLayoutConstraint!
    @IBOutlet weak var popoverViewWidth: NSLayoutConstraint!
    @IBOutlet weak var popoverView: UIImageView!
    @IBOutlet var buttonArray: [BKAdjustButton]!
//    @IBOutlet weak var scanBtn: BKAdjustButton!
    @IBOutlet weak var addFriendBtn: BKAdjustButton!
    @IBOutlet weak var creatGroupBtn: BKAdjustButton!
    var addActionType : ContactAddBtnType = .createGroup
    var topViewController : UIViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        var index = 0
        for btn in buttonArray {
            btn.titleFont       = CYLayoutConstraintFont(15.5)
            btn.textAlignment   = .left
            btn.tag             = index
            btn.addTarget(self, action: #selector(BYContactPopoverView.buttonClick(btn:)), for: .touchUpInside)
            index += 1
        }
        
        self.popoverViewTop.updateConstraint(91.0)
        self.popoverViewRight.updateConstraint(20.0)
        self.popoverViewWidth.updateConstraint(138.0)
        self.popoverViewHeight.updateConstraint(100.0)
        self.popoverTopViewRight.updateConstraint(34.0)
        
    }
    
    @objc func buttonClick(btn : BKAdjustButton) {
        let actionType  = ContactAddBtnType(rawValue: btn.tag)
        self.delegate?.didSelectButton(self, type: actionType!)
        self.disMiss()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.disMiss()
    }
    
    func disMiss() {
        self.delegate?.didDismissPopoverView(self)
        self.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        adjustButtonFrames(imageLeft: 20.0, imageSize: CGSize(width : 18.0,height : 16.0), button: self.creatGroupBtn)
        adjustButtonFrames(imageLeft: 20.5, imageSize: CGSize(width : 20.0,height : 15.5), button: self.addFriendBtn)
        
    }
    
    /// 调整button 内部的 imageView 和 titlelabel 的位置
    func adjustButtonFrames(imageLeft : CGFloat ,imageSize: CGSize,button : BKAdjustButton) {
        
        // 创建群按钮
        let imageViewWidth    : CGFloat         = CYLayoutConstraintValue(imageSize.width)
        let imageViewHeight   : CGFloat         = CYLayoutConstraintValue(imageSize.height)
        let imageViewLeft                       = CYLayoutConstraintValue(imageLeft)
        let imageViewTop                        = (button.height - imageViewHeight) * 0.5
        button.imageViewFrame                   = CGRect(x: imageViewLeft, y: imageViewTop, width: imageViewWidth, height: CGFloat(imageViewHeight))
        let labelX  : CGFloat                   = CYLayoutConstraintValue(55.0)
        let labelY  : CGFloat                   = 0.0
        let labelW  : CGFloat                   = button.width - labelX
        let labelH  : CGFloat                   = button.height
        button.titleLabelFrame                  = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)

    }
    
    deinit {
        
        NJLog(self)
        
    }
    
    
}
