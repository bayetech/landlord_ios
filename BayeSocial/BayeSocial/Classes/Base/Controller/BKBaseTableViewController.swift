//
//  BKBaseTableViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/24.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 公共的 UITableViewController 方便以后拓展
class BKBaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor           = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        self.tableView.backgroundColor      = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        self.tableView.tableFooterView      = UIView()
        
    }
   
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(CYLayoutConstraintValue(17.5))
    }

    
}
