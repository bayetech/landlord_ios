//
//  BKGroupCategoryViewCell.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/26.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

class BKGroupCategoryViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var iconView: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    /// 设置分类icon 和标题
    func setIconTitle(icon :String,title : String) {
        
        self.titleLabel.text = title
//        let url              = URL(string: icon)
////        self.iconView.kf.setImage(with: url, for: .normal)
//  
        
        
    }
    
}
