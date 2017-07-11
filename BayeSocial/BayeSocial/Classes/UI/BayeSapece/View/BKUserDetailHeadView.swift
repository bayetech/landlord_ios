//
//  BKUserDetailHeadView.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/4.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

@objc protocol BKUserDetailHeadViewDelegate  : NSObjectProtocol {
    
    /// 点击了返回的按钮
    @objc optional func userDetailHeadViewDidSelectBackAction(_ headView :BKUserDetailHeadView)
    
    /// 点击了右侧的编辑资料按钮
    @objc optional func userDetailHeadViewDidSelectEditingInfoAction(_ headView :BKUserDetailHeadView)
    
    /// 点击了头像
    @objc optional func userDetailHeadViewDidSelectAvatarImageView(_ headView :BKUserDetailHeadView)
    
}

class BKUserDetailHeadView: UIView {

    @IBAction func editingInfo(_ sender: UIButton) {
        self.delegate?.userDetailHeadViewDidSelectEditingInfoAction?(self)
    }
    @IBAction func back(_ sender: BKAdjustButton) {
        self.delegate?.userDetailHeadViewDidSelectBackAction?(self)
    }
    weak var delegate : BKUserDetailHeadViewDelegate?
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.addTarget(self, action: #selector(BKUserDetailHeadView.back(_:)))
            titleLabel.font = CYLayoutConstraintFont(17.0)
        }
    }
    @IBOutlet weak var arrowButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var arrowImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewRight: NSLayoutConstraint!
    @IBOutlet weak var editImageVIewRight: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var companyLabelTop: NSLayoutConstraint!
    @IBOutlet weak var jobTitleLabelTop: NSLayoutConstraint!

    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.addTarget(self, action: #selector(avatarImageViewClick))
            avatarImageView.setCornerRadius(CYLayoutConstraintValue(60.0))
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
//            saveButton.isHidden = true
        }
    }
    @IBOutlet weak var companyLabel: UILabel! {
        didSet {
            companyLabel.font = CYLayoutConstraintFont(16.0)
        }
    }
    @IBOutlet weak var jobTitleLabel: UILabel! {
        didSet {
            jobTitleLabel.font = CYLayoutConstraintFont(15.0)
        }
    }
//    @IBOutlet weak var ageButton: BKAdjustButton! {
//        didSet {
//            
//            ageButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#63CAF2"), forState: .normal)
//            ageButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#F35656"), forState: .selected)
//            ageButton.setImage(UIImage.init(named: "baye_sex_woman"), for: .selected)
//            ageButton.setImage(UIImage.init(named: "baye_sex_man"), for: .normal)
//            ageButton.titleFont             = CYLayoutConstraintFont(16.0)
//            ageButton.layer.cornerRadius    = CYLayoutConstraintValue(4.0)
//            ageButton.layer.masksToBounds   = true
//            ageButton.isSelected            = false
//            
//        }
//    }
    @IBOutlet weak var namelabelRight: NSLayoutConstraint!
    @IBOutlet weak var nickNameLabel: UILabel! {
        didSet {
            nickNameLabel.font = CYLayoutConstraintFont(30.0)
        }
    }
    @IBOutlet weak var nickLabelTop: NSLayoutConstraint!
//    @IBOutlet weak var titleLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var arrowButtonLeft: NSLayoutConstraint!
    @IBOutlet weak var arrowButtonTop: NSLayoutConstraint!
    @IBOutlet weak var arrowButton: BKAdjustButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.arrowButtonTop.updateConstraint(34.0)
        self.arrowButtonLeft.updateConstraint(11.5)
        self.arrowImageViewWidth.updateConstraint(30.0)
        self.arrowButtonHeight.updateConstraint(20.0)
        
        self.editImageVIewRight.updateConstraint(12.0)
        
        self.nickLabelTop.updateConstraint(20.0)
        self.namelabelRight.updateConstraint(5.0)
//        self.ageButtonLeft.updateConstraint(11.0)
//        self.ageButtonWidth.updateConstraint(50.0)
//        self.ageButtonHeight.updateConstraint(27.5)
        
        self.jobTitleLabelTop.updateConstraint(5.0)
        self.companyLabelTop.updateConstraint(3.0)
        
        self.avatarImageViewRight.updateConstraint(12.0)
        self.avatarImageViewWidth.updateConstraint(120.0)
        self.avatarImageViewHeight.updateConstraint(120.0)
        
        
    }
    
    /// 点击了头像
    @objc func avatarImageViewClick() {
        delegate?.userDetailHeadViewDidSelectAvatarImageView?(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.arrowButton.setImageViewSizeEqualToCenter(CGSize(width: CYLayoutConstraintValue(13.0), height: CYLayoutConstraintValue(20.0)))
        
//        let frame                       = self.ageButton.frame
//        
//        let imageLeft                   = CYLayoutConstraintValue(6.5)
//        let imageTop                    = CYLayoutConstraintValue(8.0)
//        let imageWidth                  = CYLayoutConstraintValue(12.0)
//        let imageHeight                 = imageWidth
//        
//        self.ageButton.imageViewFrame   = CGRect(x: imageLeft, y: imageTop, width: imageWidth, height: imageHeight)
//        
//        let titleLeft                   = imageLeft + imageWidth + CYLayoutConstraintValue(5.0)
//        let titleWidth                  = frame.size.width - titleLeft
//        
//        self.ageButton.titleLabelFrame  = CGRect(x: titleLeft, y: 0.0, width: titleWidth, height: frame.size.height)
//        
//        
    }
}
