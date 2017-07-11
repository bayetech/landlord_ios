//
//  BKChatSettingViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/3.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

@objc protocol BKChatSettingViewControllerDelegate : NSObjectProtocol {
    
    /// 清除聊天历史记录
   @objc optional func chatSettingViewControllerDidCleanHistroy(_ viewController : BKChatSettingViewController)
}

/// 聊天设置

class BKChatSettingViewController: BKBaseViewController {
    var userId : String = "" {
        didSet {
            NJLog(userId)
        }
    }
    lazy var tableView : UITableView = {
        let tableView                   = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate              = self
        tableView.dataSource            = self
        return tableView
    }()
    var needCleanChatHistory : Bool     = true
    var switchOpenStatus : [Int : Bool] = [Int : Bool]()
    public weak var delegate : BKChatSettingViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.switchOpenStatus[0] = false
        self.loadDatas()
        
    }
    var contact : BKCustomersContact?
    var dataArray : [[[String : String]]]?
    func setup() {
        self.automaticallyAdjustsScrollViewInsets = true
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!)
        }
    }
    
    func loadDatas() {
        
        self.dataArray = [
            [["title" : "加入黑名单"]],
            [["title" : "清空聊天记录"]],[["title" : "删除"],
            ["title" : "举报"]]
        ]
    
        // 获取该联系人的信息
        reqeustCustomersInfo()
        
        // 查询是否在黑名单列表里
        let inBlackList             = BKRealmManager.shared().customer(inBlackList: self.userId)
        
        self.switchOpenStatus[0]    = inBlackList
        
        self.tableView.reloadData()
        
    }
    
    func reqeustCustomersInfo() {
        
        BKNetworkManager.getOperationReqeust(KURL_Customer_friends, params: ["uids" : self.userId], success: {[weak self] (result) in
            
            let json        = result.value
            let customers   = json["customers"]?.arrayValue
            guard customers != nil else {
                UnitTools.addLabelInWindow("获取联系人失败!", vc:self)
                return
            }
            
            let array       = BKCustomersContact.customersWithJSONArray(customers!)
            self?.contact    = array.last
            
        }) {[weak self]  (result) in
            UnitTools.addLabelInWindow("获取联系人失败!", vc:self)
        }
        

    }
    
    /// 删除好友
    func deleteFriend() {
        
        let userName            = self.contact?.name ?? ""
        let msg                 = String(format: "将联系人“ %@ ” 删除，同时删除与该联系人的聊天记录", userName)
        
        let _ = YepAlertKit.showAlertView(in: self, title: nil, message: msg, titles: ["取消"], cancelTitle: nil, destructive: "删除") {[weak self] (index) in
            
            guard index == 1000 else {
                return
            }
            
            let uid = self?.contact?.uid ?? ""
            
            BKNetworkManager.postOperationReqeust(baseURLPath + "customer_friends/remove", params: ["customer_uid":uid], success: {[weak self] (success) in
                
                let return_message = success.value["return_message"]?.string ?? "删除联系人失败"
                let return_code    = success.value["return_code"]?.intValue ?? 0
                if return_code != 200 {
                    UnitTools.addLabelInWindow(return_message, vc: self)
                    return
                }
                
                // 从数据库中删除联系人信息
                BKRealmManager.shared().deleteEaseMobContact(by: uid)
                BKRealmManager.shared().deleteSendListModel(uid)
                BKRealmManager.shared().deleteContactReqeust(uid)
                // 删除会话内容
                EMClient.shared().chatManager.deleteConversation(uid, isDeleteMessages: true, completion: nil)
                
                let _ = self?.navigationController?.popToRootViewController(animated: true)
                
                
            } , failure: {[weak self] (failure) in
                
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
                
            })
            
            
        }

    }
    
    /// 清空聊天记录
    func cleanChatHistory() {
        
        let userName            = self.contact?.name ?? ""

        let _ = YepAlertKit.showAlertView(in: self, title: nil, message: "确定删除和\(userName)的聊天记录吗?", titles:  nil, cancelTitle: "取消", destructive: "清空") {[weak self] (index) in
            
            if index == 1000 {
                self?.delegate?.chatSettingViewControllerDidCleanHistroy?(self!)
            }
            
        }
        
    }
    
    /// 添加用户到黑名单列表
    func addUser(toBlackList : String,switchView : UISwitch) {
        
        EMClient.shared().contactManager.addUser(toBlackList : toBlackList, completion: {[weak self] (user, error) in
            HUD.hide(animated: true)
            guard error == nil else {
                switchView.isOn = !switchView.isOn
                UnitTools.addLabelInWindow("加入到黑名单失败", vc: self)
                return
            }
            UnitTools.addLabelInWindow("加入到黑名单成功", vc: self)
            BKRealmManager.shared().insertUserBlackList([(self?.contact)!])

        })
        
    }
    
    /// 将用户从黑名单列表移除掉
    func removeUser(from blickList : String, switchView : UISwitch) {
        
        EMClient.shared().contactManager.removeUser(fromBlackList: blickList) {[weak self] (userId, error) in
            
            HUD.hide(animated: true)
            guard error == nil else {
                switchView.isOn = !switchView.isOn
                UnitTools.addLabelInWindow("移除黑名单失败", vc: self)
                return
            }
            
            UnitTools.addLabelInWindow("移除黑名单成功", vc: self)
            BKRealmManager.shared().removeUser(fromBlacklist: (self?.contact)!)
            
        }
        
    }
    
    /// 选择了 switch 开关
    @objc func swictchValueChanged(_ switchView : UISwitch) {
        
        self.switchOpenStatus[switchView.tag] = switchView.isOn
        self.tableView.reloadRows(at: [IndexPath(row: switchView.tag, section: 0)], with: .automatic)
        
        if switchView.tag == 0 { // 拉黑
            HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
            if switchView.isOn {
                self.addUser(toBlackList:  self.userId, switchView: switchView)
            } else {
                self.removeUser(from: self.userId, switchView: switchView)
            }
         
            
        } else { // 置顶
            
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKChatSettingViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.dataArray?.count != nil else {
            return 0
        }
        return (self.dataArray!.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && !self.needCleanChatHistory {
            return 0
        } else {
            let arr     = self.dataArray?[section]
            return arr!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell                        = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.selectionStyle            = .none
        let arr                         = self.dataArray?[indexPath.section]
        let dic                         = arr?[indexPath.row]
        let title                       = dic?["title"]
        cell?.textLabel?.text           = title
        
        if indexPath.section == 0 {
            // 开关switch
            let switchView              = UISwitch()
            switchView.tag              = indexPath.row
            switchView.onTintColor      = UIColor.colorWithHexString("#FAB66F")
            switchView.addTarget(self, action: #selector(swictchValueChanged(_ :)), for: .valueChanged)
            cell?.accessoryView         = switchView
            switchView.setOn(self.switchOpenStatus[indexPath.row] ?? false, animated: false)
            
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            self.cleanChatHistory()
            
        } else if indexPath.section == 2 && indexPath.row == 0 {
            
            self.deleteFriend()
            
        } else if indexPath.section == 2 && indexPath.row == 1 {
            
            self.reportAction()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(10.0)
    }
    
    
}

// MARK: - UserReport 举报功能
extension BKChatSettingViewController {
    
    
    /// 获取举报内容
    func reportAction() {
        
        guard !self.userId.isEmpty else {
            UnitTools.addLabelInWindow("举报失败", vc: self)
            return
        }
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getOperationReqeust(KURL_ReportOptions, params: nil, success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json           = success.value
            let report_options = json["report_options"]?.arrayObject
            guard report_options != nil else {
                UnitTools.addLabelInWindow("获取举报内容失败!", vc:  self)
                return
            }
            self?.showReportActionSheet(report_options as! [String])
        }) { (failure) in
            UnitTools.addLabelInWindow("获取举报内容失败!", vc:  self)
        }
        
    }
    
    /// 展示举报选项
    func showReportActionSheet(_ reports : [String]) {
        
        let _ = YepAlertKit.showActionSheet(in: self, title: "举报部落", message:  nil, titles: reports, cancelTitle: "取消", destructive: nil) {[weak self] (index) in
            if (index != 0) {
                self?.startReport(with: reports[index-1] , customerId:self?.userId ?? "")
            }
        }
        
    }
    
    /// 开始举报用户
    func startReport(with reason : String,customerId : String) {
        
        BKNetworkManager.postOperationReqeust(KURL_StartReportCustomer, params: ["customer_uid" : customerId,"message" : reason], success: {[weak self] (success) in
            
            let json           = success.value
            let return_code         = json["return_code"]?.intValue ?? 0
            
            if return_code != 201 {
                let msg   = json["return_message"]?.string ?? "举报用户失败"
                UnitTools.addLabelInWindow(msg, vc: self)
                return
            } 
            UnitTools.addLabelInWindow("举报成功", vc: self)
        }) {[weak self]  (failure) in
            UnitTools.addLabelInWindow("网络错误,举报用户失败", vc:  self)
        }
        
    }

    
}
