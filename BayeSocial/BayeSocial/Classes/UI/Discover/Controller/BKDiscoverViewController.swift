//
//  BKDiscoverViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 巴爷汇发现页面
class BKDiscoverViewController: BKBaseViewController {

    var tableView: UITableView              = UITableView(frame: CGRect.zero, style: .grouped)
    var titleLabel : UILabel?
    var dataArray : [[[String : String]]]   = [[[String : String]]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets       = false
        self.setup()
        
    }
    
    func setup() {
        
        self.view.addSubview(self.tableView)
        self.tableView.delegate                     = self
        self.tableView.dataSource                   = self
        self.tableView.tableFooterView              = UIView()
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!)
        }
        
        addHeadView()
        loadDatas()

    }
    
    func loadDatas() {
        
        var dict1                   = [String : String]()
        dict1["icon"]               = "business_line"
        dict1["title"]              = "巴圈"
        dict1["image"]              = "addfriend_contact_icon"
        
        var dict2                   = [String : String]()
        dict2["icon"]               = "mine_friends"
        dict2["title"]              = "找部落"
        
        var dict3                   = [String : String]()
        dict3["icon"]               = "by_newReqeust"
        dict3["title"]              = "找人脉"
        
//        var dict4                   = [String : String]()
//        dict4["icon"]               = "addfriend_scanQRCode"
//        dict4["title"]              = "扫一扫"
        
        self.dataArray.append([dict1])
        self.dataArray.append([dict2,dict3])
     
        if (BKGlobalOptions.curret.wechatStoreIsVisible) {
            var dict5                   = [String : String]()
            dict5["icon"]               = "baye_store"
            dict5["title"]              = "供销社"
            self.dataArray.append([dict5])
        }

        self.tableView.reloadData()
    }
    
    func addHeadView() {
        
        let headView                                    = UIView()
        headView.frame                                  = CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(125.0))
        headView.backgroundColor                        = UIColor.white
        self.tableView.tableHeaderView                  = headView
        
        self.titleLabel                                 = UILabel()
        self.titleLabel? .text                          = "发现"
        self.titleLabel? .font                          = CYLayoutConstraintFont(30.0)

        headView.addSubview(self.titleLabel!)
        self.titleLabel?.snp.makeConstraints { (make) in
            make.top.equalTo(headView.snp.top).offset(CYLayoutConstraintValue(43.0))
            make.left.equalTo(headView.snp.left).offset(CYLayoutConstraintValue(20.0))
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.separatorInset = UIEdgeInsets.zero
     
    }
    
 
  
}


// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKDiscoverViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataArray.count == 0 {
            return 0
        }
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = self.dataArray[section]
        return arr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.accessoryType             = .disclosureIndicator
            cell?.selectionStyle            = .none
            // iconView
            let iconView                    = UIImageView()
            iconView.image                  = UIImage(named: "addfriend_scan_icon")
            iconView.tag                    = 100
            iconView.layer.cornerRadius     = CYLayoutConstraintValue(13.75)
            iconView.layer.masksToBounds    = true
            cell?.contentView.addSubview(iconView)
            iconView.snp.makeConstraints({ (make) in
                make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(19.0))
                make.centerY.equalTo((cell?.contentView)!)
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(27.5), height: CYLayoutConstraintValue(27.5)))
            })
            
            let titleLabel                  = UILabel()
            titleLabel.tag                  = 200
            titleLabel.text                 = "巴圈"
            titleLabel.font                 = CYLayoutConstraintFont(16.0)
            cell?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(iconView.snp.right).offset(CYLayoutConstraintValue(12.0))
                make.centerY.equalTo((cell?.contentView)!)
            }
            
//            let rightImageView                  = UIImageView()
//            rightImageView.tag                  = 500
//            cell?.contentView.addSubview(rightImageView)
//            rightImageView.layer.cornerRadius   = CYLayoutConstraintValue(2.0)
//            rightImageView.layer.masksToBounds  = true
////            rightImageView.backgroundColor      = UIColor.RandomColor()
//            rightImageView.snp.makeConstraints { (make) in
//                make.centerY.equalTo((cell?.contentView)!)
//                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(29.0), height: CYLayoutConstraintValue(29.0)))
//                make.right.equalTo((cell?.contentView.snp.right)!)
//            }
//            
//            let badgeValue                  = UIView()
//            badgeValue.backgroundColor      = UIColor.colorWithHexString("#F2472F")
//            badgeValue.tag                  = 700
//            badgeValue.layer.cornerRadius   = CYLayoutConstraintValue(3.75)
//            badgeValue.layer.masksToBounds  = true
//            cell?.contentView.addSubview(badgeValue)
//            badgeValue.snp.makeConstraints { (make) in
//                make.top.equalTo((cell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(4.0))
//                make.right.equalTo((cell?.contentView.snp.right)!).offset(CYLayoutConstraintValue(3.0))
//                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(7.5), height: CYLayoutConstraintValue(7.5)))
//            }
//            
            
        }
        
        
        
        let iconView                    = cell?.contentView.viewWithTag(100) as? UIImageView
        let titleLabel                  = cell?.contentView.viewWithTag(200) as? UILabel
//        let rightImageView              = cell?.contentView.viewWithTag(500) as? UIImageView
        
        let arr                         = self.dataArray[indexPath.section]
        var dict : [String : String]    = arr[indexPath.row]
            
        iconView?.image                 = UIImage(named: dict["icon"]!)
        titleLabel?.text                = dict["title"]
        
        if indexPath.section == 2 {
            titleLabel?.textColor = UIColor.colorWithHexString("#CF5555")
        } else {
            titleLabel?.textColor  = UIColor.black
        }
        
//        if let image                    = dict["image"] {
//            rightImageView?.image       = UIImage.init(named: image)
//        }
//        
//        let badgeValue                  = cell?.contentView.viewWithTag(700)
        
//        badgeValue?.isHidden            = indexPath.section != 0
//        rightImageView?.isHidden        = indexPath.section != 0
//        
//        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(44.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(25.5)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        switch (indexPath.section,indexPath.row) {
        case  (0,0): // 巴圈
            
            let communityViewController                         = BKCommunityViewController()
            communityViewController.hidesBottomBarWhenPushed    = true
            self.navigationController?.pushViewController(communityViewController, animated: true)
            
            break
   
//        case (,0) : // 扫一扫
//            
//            let scanQRCodeViewController                        = BKScanQRCodeViewController()
//            scanQRCodeViewController.hidesBottomBarWhenPushed   = true
//            self.navigationController?.pushViewController(scanQRCodeViewController, animated: true)
//
//            break
        case  (2,0): // 供销社
            
            let storeViewController                                 = BKStoreViewController()
            storeViewController.hidesBottomBarWhenPushed            = true
            storeViewController.title                               = "巴爷供销社"
            self.navigationController?.pushViewController(storeViewController, animated: true)

//            
            break
        
        default:
  
            if indexPath.row == 0 {
                //找社群
                let searchGroupViewController                           = BKSearchGroupViewController()
                searchGroupViewController.searchType                    = .searchRemoteGroup
                searchGroupViewController.hidesBottomBarWhenPushed      = true
                self.navigationController?.pushViewController(searchGroupViewController, animated: false)
                
            } else {
                
                // 找人脉
                let searchContatcViewController             = BKSearchContactViewController()
                searchContatcViewController.searchType      = .searchRemoteContact
                searchContatcViewController.hidesBottomBarWhenPushed      = true
                self.navigationController?.pushViewController(searchContatcViewController, animated: false)
                
            }
      
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
    }
    
}


