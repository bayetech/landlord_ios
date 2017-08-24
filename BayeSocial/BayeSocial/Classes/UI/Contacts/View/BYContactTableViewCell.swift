//
//  BYContactTableViewCell.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 巴爷汇人脉联系人的 cell\

protocol BYContactTableViewCellDelegate : NSObjectProtocol {
    func didSelectUserAvatar(_ cell : BYContactTableViewCell)
}

class BYContactTableViewCell: UITableViewCell {

    weak var delegate : BYContactTableViewCellDelegate?
    @IBOutlet weak var nameLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var headImageViewLeft: NSLayoutConstraint!
    @IBOutlet weak var headImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var headImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.headImageViewLeft.updateConstraint(20.0)
        self.headImageViewWidth.updateConstraint(35.0)
        self.headImageViewHeight.updateConstraint(35.0)
        self.nameLabelLeft.updateConstraint(10.0)
        self.headImageView.layer.cornerRadius   = CYLayoutConstraintValue(17.5)
        self.headImageView.layer.masksToBounds  = true
//        self.headImageView.addTarget(self, action: #selector(headImageViewClick))
        
    }

    func headImageViewClick() {
        
        self.delegate?.didSelectUserAvatar(self)
    }
}
