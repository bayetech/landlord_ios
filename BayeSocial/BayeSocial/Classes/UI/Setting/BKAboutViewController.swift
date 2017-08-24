//
//  BKAboutViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/24.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

/// 关于我们
class BKAboutViewController: BKBaseViewController {
    
    var tableView : UITableView!
    var dataArray : [[String : String]] = [[String : String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor               = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        self.title                              = "关于我们"
        self.tableView                          = UITableView(frame: CGRect.zero, style: .plain)
        self.tableView.backgroundColor          = UIColor.clear
        self.tableView.delegate                 = self
        self.tableView.dataSource               = self
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!).inset(UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0))
        }
        
        // 头部视图
        let headView : UIView                   = UIView()
        self.tableView.tableHeaderView          = headView
        headView.snp.makeConstraints {[weak self] (make) in
            make.top.left.equalTo((self?.tableView)!)
            make.size.equalTo(CGSize(width:KScreenWidth, height: CYLayoutConstraintValue(200.0)))
        }
        
        // 公司 logoView
        let logoView                            = UIImageView()
        logoView.image                          = UIImage(named: "LOGO")
        headView.addSubview(logoView)
        logoView.snp.makeConstraints { (make) in
            make.top.equalTo(headView.snp.top).offset(CYLayoutConstraintValue(40.0))
            make.centerX.equalTo(headView)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(100.0), height: CYLayoutConstraintValue(100.0)))
        }
        // 应用版本号
        let versionLabel                        = UILabel()
        let version                             = UnitTools.appCurrentVersion()
        versionLabel.text                       = String(format: "巴爷汇%@", version)
        headView.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoView.snp.bottom).offset(CYLayoutConstraintValue(15.0))
            make.centerX.equalTo(headView)
        }
        
        self.tableView.tableFooterView          = UIView()
        self.dataArray                          = [
            //                ["title" : "给我评分"],
            ["title" : "巴爷汇用户协议"]
        ]
        
        self.tableView.delayReload(with: 0.1)
        
        
    }
    
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BKAboutViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell                                = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.selectionStyle                = .none
            cell?.accessoryType                 = .disclosureIndicator
        }
        
        cell?.textLabel?.text                   = self.dataArray[indexPath.row]["title"]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 {
            
            // 给应用评分
            let urlString           = String(format: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8", "1050100674")
            let url = URL(string:urlString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: { (result) in
                    if !result {
                        UnitTools.addLabelInWindow("给应用评分失败", vc: self)
                    }
                })
            } else {
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.openURL(url!)
                } else {
                    UnitTools.addLabelInWindow("给应用评分失败", vc: self)
                }
            }
            
        } else { // 巴爷汇用户协议
            
            let legalViewController : LegalViewController   = LegalViewController()
            let nav : BKNavigaitonController                = BKNavigaitonController(rootViewController: legalViewController)
            self.present(nav, animated: true, completion: nil)
            
        }
    }
}
