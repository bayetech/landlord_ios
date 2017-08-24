//
//  BKBlackListViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/24.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import PKHUD

/// 黑名单
class BKBlackListViewController: BKBaseTableViewController {

    var customerArray : [BKCustomersContact] = [BKCustomersContact]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title      = "黑名单"
      
        self.loadDatas()
    }
    
    /// 重新加载数据
    func loadDatas() {
        
        // 读取本地黑名单列表
        self.customerArray = BKRealmManager.shared().readUserBlackList()
        
       // 请求网络黑名单列表
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        EMClient.shared().contactManager.getBlackListFromServer {[weak self] (blackList, error) in
            HUD.hide(animated: true)
            guard error == nil else {
                UnitTools.addLabelInWindow("获取黑名单列表失败", vc: self)
                return
            }
            if blackList?.count == 0 {
                return
            }
            let uids = UnitTools.arrayTranstoString(blackList as! [String])
            self?.requestCustomerInfo(uids)
            
        }
        
    }
    
    /// 请求黑名单用户资料
    func requestCustomerInfo(_ uids : String) {
        AppDelegate.appDelegate().reqeustCustomerUserList(uids) {[weak self] (customers) in
            self?.customerArray = customers
            BKRealmManager.shared().insertUserBlackList((self?.customerArray)!)
            self?.tableView.reloadData()
        }
        
    }
    
    /// 移除黑名单
    @objc func removeButtonClick(_ btn : UIButton,event : Any) {
        
       let indexPath = btn.indexPath(at: self.tableView, forEvent: event)
        guard indexPath != nil else {
            return
        }
        let cutomerModel    = self.customerArray[(indexPath?.row)!]
        EMClient.shared().contactManager.removeUser(fromBlackList: cutomerModel.uid) {[weak self] (user, error) in
            guard error == nil else {
                UnitTools.addLabelInWindow("移除黑名单失败", vc: self)
                return
            }
            self?.customerArray.remove(at: (indexPath?.row)!)
            self?.tableView.deleteRows(at: [indexPath!], with: .automatic)
            BKRealmManager.shared().removeUser(fromBlacklist: cutomerModel)
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customerArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.selectionStyle            = .none
            // iconView
            let iconView                    = UIImageView()
            iconView.tag                    = 100
            iconView.setCornerRadius(CYLayoutConstraintValue(25.0))
            cell?.contentView.addSubview(iconView)
            iconView.snp.makeConstraints({ (make) in
                make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(16.0))
                make.centerY.equalTo((cell?.contentView)!)
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(50.0), height: CYLayoutConstraintValue(50.0)))
            })
            
            // 申请加群
            let removeButton                             = UIButton(type: .custom)
            removeButton.setTitle("移出黑名单", for: .normal)
            removeButton.setTitleColor(UIColor.white, for: .normal)
            removeButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#24B497"), forState: .normal)
            removeButton.titleLabel?.font                = CYLayoutConstraintFont(14.0)
            removeButton.titleLabel?.textAlignment       = .center
            removeButton.layer.cornerRadius              = CYLayoutConstraintValue(3.0)
            removeButton.layer.masksToBounds             = true
            removeButton.tag                             = 500
            removeButton.addTarget(self, action: #selector(removeButtonClick(_:event:)), for: .touchUpInside)
            cell?.contentView.addSubview(removeButton)
            removeButton.snp.makeConstraints({ (make) in
                make.centerY.equalTo((cell?.contentView)!)
                make.right.equalTo((cell?.contentView.snp.right)!).offset(-CYLayoutConstraintValue(13.0))
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(80.0), height: CYLayoutConstraintValue(30.0)))
            })
            
            // 主标题
            let titleLabel                  = UILabel()
            titleLabel.tag                  = 200
            titleLabel.font                 = CYLayoutConstraintFont(16.0)
            cell?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(iconView.snp.right).offset(CYLayoutConstraintValue(9.0))
                make.top.equalTo((cell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(9.0))
                make.right.equalTo(removeButton.snp.left).offset(-CYLayoutConstraintValue(10.0))
            }
            
            // 子标题
            let subTitleLabel               = UILabel()
            subTitleLabel.tag               = 300
            subTitleLabel.font              = CYLayoutConstraintFont(14.0)
            subTitleLabel.textColor         = UIColor.colorWithHexString("#777777")
            cell?.contentView.addSubview(subTitleLabel)
            subTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo((titleLabel.snp.bottom)).offset(CYLayoutConstraintValue(5.0))
                make.left.right.equalTo(titleLabel)
                
            }
            
        }
        
        let customerModel                       = self.customerArray[indexPath.row]
        
        let imageView                           = cell?.contentView.viewWithTag(100) as? UIImageView
        imageView?.kf.setImage(with: URL(string : customerModel.avatar), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        
        // 标题
        let label                               = cell?.contentView.viewWithTag(200) as? UILabel
        label?.text                             = customerModel.name
        
        let subLabel                            = cell?.contentView.viewWithTag(300) as? UILabel
        subLabel?.text                          = String(format: "%@ %@", customerModel.company,customerModel.company_position)
        
        
        return cell!
        
    }
    
   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(60.0)
    }

}
