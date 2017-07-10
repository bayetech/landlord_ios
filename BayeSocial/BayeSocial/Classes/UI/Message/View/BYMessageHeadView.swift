//
//  BYMessageHeadView.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

@objc protocol BYMessageHeadViewDelegate : NSObjectProtocol {
    
    /// 选择了添加的按钮
    @objc optional func by_MessageHeadHeadView(_ didSelectAddBtn : BYMessageHeadView)
    
    /// 点击了搜索输入框
    @objc optional func by_MessageHeadHeadViewDidSelectSearchTextField(_ headView : BYMessageHeadView)
    
}
/// 消息页面的头部视图
class BYMessageHeadView: UIView {

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = CYLayoutConstraintFont(30.0)
        }
    }
    @IBOutlet weak var addFriendBtnRight: NSLayoutConstraint!
    @IBOutlet weak var addFriendBtnTop: NSLayoutConstraint!
    @IBOutlet weak var titleLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTop: NSLayoutConstraint!
    @IBOutlet weak var textFieldTop: NSLayoutConstraint!
    @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var textFieldLeft: NSLayoutConstraint!
    @IBOutlet weak var textFieldRight: NSLayoutConstraint!
    @IBOutlet weak var textField: BKSearchTextField! {
        didSet {
            textField.delegate = self
        }
    }
    weak var delegate : BYMessageHeadViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabelTop.updateConstraint(43.0)
        self.titleLabelLeft.updateConstraint(19.0)
        self.addFriendBtnRight.updateConstraint(20.0)
        self.addFriendBtnTop.updateConstraint(41.0)
        self.textFieldHeight.updateConstraint(35.0)
        self.textFieldLeft.updateConstraint(18.0)
        self.textFieldRight.updateConstraint(18.0)
        self.textFieldTop.updateConstraint(34.0)

    }
    
    /// 添加按钮
    @IBAction func didSelectAddBtn(_ sender: UIButton) {
        
        delegate?.by_MessageHeadHeadView!(self)
    }

}


// MARK: - UITextFieldDelegate
extension BYMessageHeadView : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.delegate?.by_MessageHeadHeadViewDidSelectSearchTextField!(self)
        
        return false
    }
    
}
