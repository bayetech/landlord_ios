//
//  BKSettingViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 设置控制器
class BKSettingViewController: BKBaseTableViewController {

    var dataSource : [[[String : String]]] = [[[String : String]]]()
    var needUpdateApp : Bool               = BKGlobalOptions.curret.needUpdateApp
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title                                  = "设置"
        self.loadDatas()
        
    }
    
    func loadDatas() {
        
        let dictOne = [
            "title" : "账号信息",
            "subTitle" : ""
        ]
        let dictTwo = [
            "title" : "消息设置",
            "subTitle" : ""
        ]
        let dictThree = [
            "title" : "隐私设置",
            "subTitle" : ""
        ]
        let dictFour = [
            "title" : "检查更新",
            "subTitle" : ""
        ]
        let dictFive = [
            "title" : "意见反馈",
            "subTitle" : ""
        ]
        let dictSix = [
            "title" : "关于我们",
            "subTitle" : ""
        ]
        let dictSevien = [
            "title" : "联系客服",
            "subTitle" : ""
        ]
        let dictEight = [
            "title" : "清除缓存",
            "subTitle" : "0.0 MB"
        ]
        let dictNine = [
            "title" : "退出",
            "subTitle" : ""
        ]
        self.dataSource.append([dictOne,dictTwo,dictThree])
        if self.needUpdateApp {
            self.dataSource.append([dictFour,dictFive,dictSix,dictSevien,dictEight])
        } else {
            self.dataSource.append([dictFive,dictSix,dictSevien,dictEight])
        }
        self.dataSource.append([dictNine])
        self.tableView?.reloadData()
        self.reloadImageCache()
    }
    
    /// 刷新用户缓存
    func reloadImageCache() {
        
        // 计算缓存大小
        BKCacheManager.shared.imageCahceSize {[weak self] (cacheSize) in
            
            var indexPath                                           = IndexPath(row: 4, section: 1)
            if !(self?.needUpdateApp)! {
                indexPath                                           = IndexPath(row: 3, section: 1)
            }
            var dict                                                = self?.dataSource[indexPath.section][indexPath.row]
            dict?["subTitle"]                                       = cacheSize
            self?.dataSource[indexPath.section][indexPath.row]      = dict!
            self?.tableView?.reloadRows(at: [indexPath], with: .automatic)
            
        }

    }
    
    /// 用户登出的方法
    func userSignOunt() {
              
        let _ = YepAlertKit.showAlertView(in: self, title: "确定要退出登录吗？", message: nil, titles: nil, cancelTitle:  "取消", destructive:  "登出") { (index) in
            if index == 1000 {
                BKCacheManager.shared.loginOutApplication()
            }
        }
        
    }
    
    /**
     电话客服
     */
    func phoneCustomer() {
        
        let str : String        = "tel:" + "15618300853";
        let url : URL           = URL(string: str)!;
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { (result) in
                if !result {
                    NJLog("拨打电话失败");
                }
            }
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url);
            }
        }
        
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BKSettingViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell                        = tableView.dequeueReusableCell(withIdentifier: "Cell")

        if cell == nil {
            cell                        = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
            cell?.selectionStyle        = .none
            cell?.accessoryType         = .disclosureIndicator
            
        }
        
        let array                       = self.dataSource[indexPath.section]
        let dict                        = array[indexPath.row]
        
        cell?.textLabel?.text           = dict["title"]
        cell?.detailTextLabel?.text     = dict["subTitle"]
        
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(17.5)

    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var row : Int = indexPath.row
        if !self.needUpdateApp && indexPath.section == 1 {
            row+=1
        }
        switch (indexPath.section,row) {
        case (0,0): // 账号信息
            let accountViewController : BKAccountViewController = BKAccountViewController()
            accountViewController.mobile                        = BK_UserInfo.mobile ?? ""
            self.navigationController?.pushViewController(accountViewController, animated: true)
            break
        case (0,1) : // 消息设置
            let notificationsViewController = BKNotificationsViewControlller()
            self.navigationController?.pushViewController(notificationsViewController, animated: true)
            
            break
        case (0,2) : // 隐私设置
            let privacySettingViewController    = BKPrivacySettingViewController()
            self.navigationController?.pushViewController(privacySettingViewController, animated: true)
            break
        case (1,0) : // 检查更新
            let url : URL = URL(string:"https://itunes.apple.com/us/app/ba-ye-hui/id1050100674?mt=8")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (result) in
                    if !result {
                        UnitTools.addLabelInWindow("无法检查更新版本", vc:self)
                    }
                })
            } else {
                // Fallback on earlier versions
                if !UIApplication.shared.canOpenURL(url) {
                    UnitTools.addLabelInWindow("无法检查更新版本", vc:self)
                    return
                }
            }
            break
        case (1,1) : // 联系客服
            let feedbackViewController : BKFeedbackViewController = BKFeedbackViewController()
            self.navigationController?.pushViewController(feedbackViewController, animated: true)
            break
        case (1,2) : // 关于我们
            let aboutViewController                 = BKAboutViewController()
            self.navigationController?.pushViewController(aboutViewController, animated: true)
            break
        case (1,3) : // 联系客服
        
            phoneCustomer()
            
            break
            
        case (1,4) : // 清理缓存
            
            
            let _ = YepAlertKit.showAlertView(in: self, title: nil, message: "只清除浏览生成的缓存，不会删除聊天记录", titles: nil, cancelTitle: "取消", destructive: "确定", callBack: {[weak self] (index) in
                if index == 1000 {
                    BKCacheManager.shared.clearImageCache()
                    self?.reloadImageCache()
                    UnitTools.addLabelInWindow("清除缓存成功", vc: self)
                }
            })
            break
        case (2,0) : // 退出
            self.userSignOunt()
            break
        default:
            
            break
        }
        
    }
    
}


