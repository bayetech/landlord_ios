//
//  BKGroupIntroducetViewCell.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/26.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

protocol BKGroupIntroducetViewCellDelegate : NSObjectProtocol {
    func didInputGroupDescription(_ cell :BKGroupIntroducetViewCell , desc : String)
}

class BKGroupIntroducetViewCell: UITableViewCell {

    @IBOutlet weak var titleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    @IBOutlet weak var textViewRight: NSLayoutConstraint!
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var textViewLeft: NSLayoutConstraint!
    @IBOutlet weak var titleLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var textView: BKTextView! {
        didSet {
          
            textView.font              = CYLayoutConstraintFont(17.0)
            textView.placeholderString = "描述这是一个怎样的部落"
            textView.placeholderColor  = UIColor.colorWithHexString("#C8C8C8")
            textView.placeholderFont   = CYLayoutConstraintFont(17.0)
            textView.delegate          = self
        }
    }
    weak var delegate : BKGroupIntroducetViewCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabelLeft.updateConstraint(22.0)
        self.titleLabelHeight.updateConstraint(44.0)
        self.textViewLeft.updateConstraint(22.0)
        self.textViewTop.updateConstraint(12.0)
        self.textViewRight.updateConstraint(12.0)
        self.textViewBottom.updateConstraint(10.0)
        
        
    }


    
}


// MARK: - UITextViewDelegate

extension BKGroupIntroducetViewCell : UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.delegate?.didInputGroupDescription(self, desc: self.textView.text)
    }
    
    
}
