//
//  BKAddFriendReqeustView.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/27.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

@objc protocol BKAddFriendReqeustViewDelegate {
    
    /// 点击了用户头像
    @objc optional func didSelectUserImageView(_ cell : BKAddFriendReqeustView , indexPath : IndexPath)
    
    /// 点击了右边的按钮
    @objc optional func didSelectButton(_ cell : BKAddFriendReqeustView , indexPath : IndexPath,isSelect : Bool)

}

class BKAddFriendReqeustView: UITableViewCell {
    
    @IBOutlet weak var nameLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var descLabel: UILabel! {
        didSet {
            descLabel.font  = CYLayoutConstraintFont(13.0)
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font  = CYLayoutConstraintFont(13.0)
        }
    }
    
    var indexPath : IndexPath?
    weak var delegate : BKAddFriendReqeustViewDelegate?
    
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.setTitleColor(UIColor.colorWithHexString("#39BBA1"), for: .selected)
            button.setTitleColor(UIColor.colorWithHexString("#FFFFFF"), for: .normal)
            button.setBackgroundColor(backgroundColor: UIColor.white, forState: .selected)
            button.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#24B497"), forState: .normal)
            button.layer.cornerRadius           = CYLayoutConstraintValue(3.0)
            button.layer.masksToBounds          = true
            button.addTarget(self, action: #selector(BKAddFriendReqeustView.buttonClick(_:)), for: .touchUpInside)
            button.setTitle("接受", for: .normal)
            button.setTitle("发消息", for: .selected)

        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.font  = CYLayoutConstraintFont(16.0)
        }
    }
    
    @IBOutlet weak var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius     = CYLayoutConstraintValue(20.0)
            iconView.layer.masksToBounds    = true
            iconView.addTarget(self, action: #selector(imageViewDidClick))
        }
    }
   
    @IBOutlet weak var titleLabelRight: NSLayoutConstraint!
    @IBOutlet weak var textLabelTop: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTop: NSLayoutConstraint!
    @IBOutlet weak var nameLabelTop: NSLayoutConstraint!
    @IBOutlet weak var buttonRight: NSLayoutConstraint!
    @IBOutlet weak var buttonTop: NSLayoutConstraint!
    @IBOutlet weak var iconViewLeft: NSLayoutConstraint!
    @IBOutlet weak var iconViewTop: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet weak var iconVIewHeight: NSLayoutConstraint!
    @IBOutlet weak var iconViewWidth: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconViewTop.updateConstraint(9.0)
        self.iconViewLeft.updateConstraint(15.0)
        self.iconVIewHeight.updateConstraint(40.0)
        self.iconViewWidth.updateConstraint(40.0)

        self.nameLabelTop.updateConstraint(8.0)
        self.nameLabelLeft.updateConstraint(10.0)
        
        self.titleLabelTop.updateConstraint(7.0)
        self.titleLabelRight.updateConstraint(5.0)
        
        self.textLabelTop.updateConstraint(5.0)
        
        self.buttonRight.updateConstraint(14.0)
        self.buttonTop.updateConstraint(20.0)
//        self.buttonWidth.updateConstraint(70.0)
        self.buttonHeight.updateConstraint(25.0)
        
        
    }
    var contact : BKCustomersContact? {
        
        didSet {
            guard contact != nil else {
                return
            }
            
            if let avatar           = contact?.avatar {
                self.iconView.kf.setImage(with: URL(string: avatar), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
            }

            self.nameLabel.text     = contact?.name
            
            self.titleLabel.text    = String(format: "%@ %@", (contact?.company)!,(contact?.company_position)!)
            
            self.descLabel.text     = contact?.applyReason
            
            let isFriend            = contact?.isFriend
                        
            self.setButtonState(isSelected: isFriend!)
            
        }
    }
    
    /// 设置 button 的状态
    func setButtonState(isSelected : Bool) {
        
        self.button.isSelected = isSelected
        
        if self.button.isSelected {
            
            self.button.layer.borderColor       = UIColor.colorWithHexString("#39BBA1").cgColor
            self.button.layer.borderWidth       = 0.5
            
        } else {
            
            self.button.layer.borderColor       = UIColor.clear.cgColor
            self.button.layer.borderWidth       = 0.0
            
        }
        
    }
    
    // 接受加好友请求或者发消息
    @objc func buttonClick(_ btn : UIButton) {
        
        self.delegate?.didSelectButton?(self, indexPath: self.indexPath!, isSelect: btn.isSelected)
    }
    
    /// 点击了用户头像
    @objc func imageViewDidClick() {
        
        self.delegate?.didSelectUserImageView?(self, indexPath: self.indexPath!)
        
    }
}
