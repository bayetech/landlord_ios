//
//  BYMessageNotificationCell.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

class BYMessageNotificationCell: UITableViewCell {

    @IBOutlet weak var badgeView: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
     @IBOutlet weak var detailLabel: UILabel! {
        didSet {
            detailLabel.font = CYLayoutConstraintFont(14.0)
        }
    }
    @IBOutlet weak var titleLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = CYLayoutConstraintFont(16.0)
        }
    }
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconViewLeft: NSLayoutConstraint!
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timelabelRight: NSLayoutConstraint!
    @IBOutlet weak var titleLabelWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.iconViewLeft.updateConstraint(18.5 )
        self.iconHeight.updateConstraint(45.0)
        self.iconWidth.updateConstraint(45.0)
        self.titleLabelLeft.updateConstraint(18.0)
        self.timelabelRight.updateConstraint(10.0)
        self.titleLabelWidth.updateConstraint(220.0)
     
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
    }
    
   
}
