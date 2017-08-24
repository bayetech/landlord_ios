//
//  BYMessageConversationViewCell.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 聊天会话的 cell

class BYMessageConversationViewCell: UITableViewCell {

    @IBOutlet weak var titleLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTop: NSLayoutConstraint!
    @IBOutlet weak var timeLabelTop: NSLayoutConstraint!
    @IBOutlet weak var timeLabelRight: NSLayoutConstraint!
    @IBOutlet weak var detailLabelTop: NSLayoutConstraint!
    @IBOutlet weak var detailLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detalLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nodisturbingBtn: UIButton!
    @IBOutlet weak var badgeLabel: UILabel! {
        didSet {
            badgeLabel.font = CYLayoutConstraintFont(11.5)
        }
    }
    @IBOutlet weak var avatarImageViewLeft : NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewHeight : NSLayoutConstraint!
    @IBOutlet weak var avatarImaeViewWidth : NSLayoutConstraint!
    @IBOutlet weak var avatarImageView : UIImageView! {
        didSet {
            self.avatarImageView.layer.masksToBounds = true
            self.avatarImageView.layer.cornerRadius = CYLayoutConstraintValue(25.0)
        }
    }
    @IBOutlet weak var badgeView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatarImaeViewWidth.updateConstraint(50.0)
        self.avatarImageViewHeight.updateConstraint(50.0)
        self.avatarImageViewLeft.updateConstraint(17.5)

        self.titleLabelTop.updateConstraint(13.0)
        self.titleLabelLeft.updateConstraint(10.0)
        self.timeLabelRight.updateConstraint(10.0)
        self.timeLabelTop.updateConstraint(13.0)
        self.detailLabelTop.updateConstraint(8.0)
        self.detailLabelWidth.updateConstraint(250.0)
        
        
    }
    
    var conversationModel : BKConversationModel? {
        didSet {
          
            let placeholderImage                = (conversationModel?.isChatGroupType)! ? KChatGroupPlaceholderImage : KCustomerUserHeadImage
            let  avatar                         = conversationModel?.avaratURLPath
            
            self.avatarImageView.kf.setImage(with: URL(string : avatar!), placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: nil)
            
            self.avatarImageView.kf.setImage(with: URL(string : avatar!), placeholder:placeholderImage , options: nil , progressBlock: nil) { (image, error, type, url) in
                
//                NJLog(image)
//                NJLog(url)

            }
            self.titleLabel.attributedText      = conversationModel?.name
            self.detalLabel.attributedText                = conversationModel?.message
            self.timeLabel.text                 = conversationModel?.date
            self.nodisturbingBtn.isHidden       = !(conversationModel?.isNotDisturb)!
            let unreadMsgCount  = conversationModel?.messageCount ?? 0
            if  unreadMsgCount != 0 {
                self.badgeView.isHidden = false
                self.badgeLabel.text    = unreadMsgCount>100 ? "99+" : String(format: "%d", unreadMsgCount)
            } else {
                self.badgeView.isHidden = true
            }
            
            self.badgeLabel.isHidden    = self.badgeView.isHidden
            
        }
        
    }
 
    

}
