//
//  BYContactHeadView.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

@objc protocol BYContactHeadViewDelegate : NSObjectProtocol {
    
    /// 选择了添加的按钮
    @objc optional func by_ContactHeadView(_ didSelectAddBtn : BYContactHeadView)
    
    /// 点击了搜索输入框
    @objc optional func by_ContactHeadViewDidSelectSearchTextField(_ headView : BYContactHeadView)
    
    ///点击了新的的请求的视图
    @objc optional func by_ContactHeadViewDidSelectNewReqeustView(_ headView :BYContactHeadView)
    
    /// 选择了我的社群
    @objc optional func by_ContactHeadViewDidSelectMyGroupView(_ headView :BYContactHeadView)
    
}

/// 人脉页面的头部视图
class BYContactHeadView: UIView {

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = CYLayoutConstraintFont(30.0)
        }
    }
    weak var delegate : BYContactHeadViewDelegate?
    @IBOutlet weak var addFriendBtnRight: NSLayoutConstraint!
    @IBOutlet weak var addFriendBtnTop: NSLayoutConstraint!
    @IBOutlet weak var titleLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTop: NSLayoutConstraint!
    @IBOutlet weak var textFieldTop: NSLayoutConstraint!
    @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var textFieldLeft: NSLayoutConstraint!
    @IBOutlet weak var textFieldRight: NSLayoutConstraint!
    @IBOutlet weak var newReqeustViewTop: NSLayoutConstraint!
    @IBOutlet weak var newRequestViewHeight: NSLayoutConstraint!
    @IBOutlet weak var newReqeustIconWidth: NSLayoutConstraint!
    @IBOutlet weak var newReqeustIconHeight: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    var leftView : UIButton?
    @IBOutlet weak var badgeView: UIImageView!
    @IBOutlet weak var mineGroupView: UIView!
    @IBOutlet weak var newReqeustView: UIView!
    @IBOutlet weak var newReqeustBadgeLabel: UILabel! {
        didSet {
            newReqeustBadgeLabel.font = CYLayoutConstraintFont(13.0)
        }
    }
    @IBOutlet weak var newReqeustLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var newReqeustIconleft: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabelTop.updateConstraint(43.0)
        self.titleLabelLeft.updateConstraint(19.0)
        self.addFriendBtnRight.updateConstraint(20.0)
        self.addFriendBtnTop.updateConstraint(41.0)
        self.textFieldHeight.updateConstraint(35.0)
        self.textFieldLeft.updateConstraint(18.0)
        self.textFieldRight.updateConstraint(18.0)
        self.textFieldTop.updateConstraint(106.0)
        self.newReqeustViewTop.updateConstraint(23.0)
        self.newRequestViewHeight.updateConstraint(55.0)
        self.newReqeustIconleft.updateConstraint(20.0)
        self.newReqeustIconWidth.updateConstraint(35.0)
        self.newReqeustIconHeight.updateConstraint(35.0)
        self.newReqeustLabelLeft.updateConstraint(11.0)
        self.newReqeustView.addTarget(self, action: #selector(BYContactHeadView.didSelectNewReqeustView(_:)))
        self.mineGroupView.addTarget(self, action: #selector(BYContactHeadView.didSelectMineGroupView(_:)))

        self.addLeftView()
        
    }
    
    func addLeftView() {
        
        let leftButton                                  = UIButton(type: .custom)
        leftButton.isUserInteractionEnabled             = false
        leftButton.setImage(UIImage(named: "By_keyword_Search"), for: .normal)
        self.textField.leftView                         = leftButton
        self.textField.leftViewMode                     = .always
        self.leftView                                   = leftButton
        self.textField.placeholder                      = "搜索"
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textField.layer.masksToBounds      = true
        self.textField.layer.cornerRadius       = self.textField.height * 0.5
        self.leftView?.frame                    = CGRect(x: 0.0, y: 0.0, width: 33.0, height: self.textField.height)
        
        
    }
    
    /// 添加按钮
    @IBAction func didSelectAddBtn(_ sender: UIButton) {
        delegate?.by_ContactHeadView!(self)
    }
    
    /// 点击了新的请求
    func didSelectNewReqeustView(_ tap : UITapGestureRecognizer) {
        delegate?.by_ContactHeadViewDidSelectNewReqeustView!(self)
    }
    /// 点击了我的社群
    func didSelectMineGroupView(_ tap : UITapGestureRecognizer) {
        delegate?.by_ContactHeadViewDidSelectMyGroupView!(self)
    }
    
}

// MARK: - UITextFieldDelegate
extension BYContactHeadView : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.delegate?.by_ContactHeadViewDidSelectSearchTextField!(self)
        return false
    }
    
}
