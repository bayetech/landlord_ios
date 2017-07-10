//
//  BKMineJoinGroupViewCell.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/28.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 我的社群的cell
class BKMineJoinGroupViewCell: UITableViewCell {

    @IBOutlet weak var avatarImgeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var disturbingBtnLeft: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewLeft: NSLayoutConstraint!
    @IBOutlet weak var descLabelRight: NSLayoutConstraint!
    @IBOutlet weak var descLabelTop: NSLayoutConstraint!
    @IBOutlet weak var groupLabelTop: NSLayoutConstraint!
    @IBOutlet weak var groupLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var nameLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var nameLabelTop: NSLayoutConstraint!
    @IBOutlet weak var descLabel: UILabel! {
        didSet {
            descLabel.font = CYLayoutConstraintFont(12.0)

        }
    }
    @IBOutlet weak var disturbingButton: UIButton!
    @IBOutlet weak var groupOwnerLabel: UILabel! {
        didSet {
            groupOwnerLabel.font = CYLayoutConstraintFont(10.0)
            groupOwnerLabel.setCornerRadius(CYLayoutConstraintValue(3.0))
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.font = CYLayoutConstraintFont(15.0)
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius  = CYLayoutConstraintValue(20.0)
            avatarImageView.layer.masksToBounds = true
        }
    }
    
    var groupModel : BKChatGroupModel? {
        didSet {
            
            if let avatar = groupModel?.avatar {
               let url = URL(string: avatar)
               self.avatarImageView.kf.setImage(with: url, placeholder: KChatGroupPlaceholderImage, options: nil, progressBlock: nil, completionHandler: nil)
            }
            
            self.nameLabel.text         = groupModel?.groupname
            self.descLabel.text         = groupModel?.desc
            
            // 判断登录用户是否是群主
            let owner_uid               = (groupModel?.owner_uid)!
            if owner_uid == KCustomAuthorizationToken.easemob_username {
                self.groupOwnerLabel.text = " 酋长 "
            } else {
                self.groupOwnerLabel.text = ""
            }
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarImageViewWidth.updateConstraint(40.0)
        self.avatarImgeViewHeight.updateConstraint(40.0)
        self.avatarImageViewLeft.updateConstraint(15.0)
        self.nameLabelTop.updateConstraint(9.0)
        self.nameLabelLeft.updateConstraint(10.0)
        
        self.groupLabelTop.updateConstraint(15.0)
        self.groupLabelLeft.updateConstraint(5.0)

        self.disturbingBtnLeft.updateConstraint(5.0)
        
        self.descLabelTop.updateConstraint(5.0)
        self.descLabelRight.updateConstraint(30.0)
        
        
    }

}
