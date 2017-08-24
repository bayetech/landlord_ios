//
//  BKSeachContactViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/28.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 搜索人脉
class BKSearchContactViewController: BKBaseSearchViewController {

    fileprivate  var localContacts : [BKCustomersContact] = [BKCustomersContact]()
    fileprivate  var recommendContacts : [BKCustomersContact] = [BKCustomersContact]()
    fileprivate var userId : String?
    fileprivate var selectIndexPath : IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
    }
    
   fileprivate func setup() {
        
        self.tableView.delegate                 = self
        self.tableView.dataSource               = self
        self.textField.placeholder              = "搜索手机号／姓名"
        if self.searchType == .searchRemoteContact {
            self.requestSuggestedUsers()

        }

    }
    
    /// 获取系统推荐用户
    fileprivate func requestSuggestedUsers() {
        self.showHUD()
        BKNetworkManager.getOperationReqeust(baseURLPath + "recommendation/people", params: nil, success: {[weak self] (success) in
            self?.hiddenHUD()
            let json                        = success.value
            let customers                   = json["customers"]?.arrayValue
            guard customers != nil else {
                return
            }
            
            self?.recommendContacts  = BKCustomersContact.customersWithJSONArray(customers!)
            
            self?.tableView.reloadData()
            
        }) { (failure) in
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tableView.reloadData()
    }
    
   
    
}


// MARK: - 添加人脉相关操作
extension BKSearchContactViewController {
    
    
    /// 添加好友信息
   @objc fileprivate func addNewFriend(_ btn : UIButton,event :Any) {
        
    
        let indexPath = btn.indexPath(at: self.tableView, forEvent: event)
        if indexPath != nil {
            if btn.currentTitle == "发消息" {
                
                let contact             = getContact(at: indexPath!)
                EMIMHelper.shared().hy_chatRoom(withConversationChatter: (contact.uid), soureViewController: self)
                
            }  else {
                
                let array               = indexPath?.section == 0 ? self.localContacts : self.recommendContacts
                let contactModel        = array[(indexPath?.row)!]
                self.showAddFreinedAlertController(contactModel.uid)
                self.selectIndexPath    = indexPath!
                
            }
         
        }
        
    }
    /// 显示说点什么
   fileprivate func showAddFreinedAlertController(_ userId : String) {
        
        self.userId                                 = userId
        let makeCallViewController                  = BKMakeCallViewController()
        makeCallViewController.leftTitle            = "好友验证"
        makeCallViewController.delegate             = self
        makeCallViewController.placeHolderString    = "你好，我是巴爷汇的\(BK_UserInfo.name)，请求添加你为好友！"
        let nav                                     = BKNavigaitonController(rootViewController: makeCallViewController)
        self.present(nav, animated: true, completion: nil)
    
    }
    
    /// 添加好友的请求
    fileprivate func addFriendReqeust(_ uid : String, msg : String) {
        
        
        BKNetworkManager.postReqeust(baseURLPath + "customer_friends/add", params: ["customer_uid" : uid,"message" : msg], success: {[weak self] (success) in
            
            let return_code         = success.value["return_code"]?.intValue ?? 0
            let return_message      = success.value["return_message"]?.stringValue ?? "请求加好友失败"
            
            if return_code != 200 {
                UnitTools.addLabelInWindow(return_message, vc: self)
                return
            }
            
            // 已经发送过加人脉的信息 用来判断是否发送过加某人的请求
            let sendModel               = BKSendList(uid: uid, account: easemob_username, type: .contact, isSend: true)
            BKRealmManager.shared().insert(sendModel)
            UnitTools.addLabelInWindow("发送添加好友申请成功", vc: self)
            self?.tableView.reloadRows(at: [(self?.selectIndexPath)!], with: .automatic)
            
        }) {[weak self] (failure) in
            
            UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
            
        }
        
        
    }
    
    
}

// MARK: - 搜索人脉相关
extension BKSearchContactViewController {
    
    /// 搜索内容发生了改变
   internal override func setupTextfieldInputText(_ string: String) {
        super.setupTextfieldInputText(string)
        
        guard string.length != 0 else {
            self.localContacts.removeAll()
            self.tableView.reloadData()
            return
        }
        
        // 本地搜索模糊查询
        if self.searchType == .searchLocalContact {
            self.searchLocalContacts(string)
        }
    
    }

    /// 搜索远程服务器人脉
    fileprivate func searchRemoteCustomers(_ keywrods : String) {
        
        if keywrods.length == 0 {
            UnitTools.addLabelInWindow("请输入要查找的用户手机号码", vc: self)
            return
        }
        
        // 判断是否添加自己为好友,不能够添加自己为好友的
        if keywrods ==  KCustomAuthorizationToken.userAccount {
            let _ =  YepAlertKit.showAlertView(in: self, title: "不能添加自己为好友", message: nil, titles: nil, cancelTitle: "取消", destructive:  nil, callBack: nil)
            return
        }
        
        self.textField.resignFirstResponder()
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.postOperationReqeust(KURL_CustomerFriendSearch, params: ["mobile_no" : keywrods], success: ({ [weak self] (success) in
            
            HUD.hide(animated: true)
            let json                        = success.value
            let customer                    = json["customer"]?.dictionaryValue
            guard customer != nil else {
                UnitTools.addLabelInWindow("该用户不存在", vc: self)
                return
            }
            
            let contactModel            = BKCustomersContact(by: JSON(customer!))
            
            self?.localContacts          = [contactModel]
            
            BKRealmManager.shared().insertCustomerContact([contactModel])
            
            self?.tableView.reloadData()

            }), failure: ({ (failure) in
                
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
                
            }))
        
        
    }
    
    /// 搜索本地通讯录
   fileprivate func searchLocalContacts(_ keywords : String) {
    
        self.localContacts  =  BKRealmManager.shared().queryCustomerUser(byKeywords: keywords)
    
        self.tableView.reloadData()
    
    }
    
    /// 开始搜索的页面
   internal  override func startSeachText(_ text : String) {
        super.startSeachText(text)
        
        if self.searchType == .searchLocalContact { // 搜索本地
            self.searchLocalContacts(text)
        } else { // 搜索网络
            self.searchRemoteCustomers(text)
        }
        
    }

    
}

extension BKSearchContactViewController : UITableViewDataSource , UITableViewDelegate   {
    
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 2
     }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.localContacts.count
        } else {
            return self.recommendContacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell")
        
        if cell == nil {
            cell                            = UITableViewCell(style: .default, reuseIdentifier: "ContactCell")
            cell?.selectionStyle            = .none
            
            // iconView
            let iconView                    = UIImageView()
            iconView.image                  = UIImage(named: "addfriend_scan_icon")
            iconView.tag                    = 100
            iconView.setCornerRadius(CYLayoutConstraintValue(22.5))
            cell?.contentView.addSubview(iconView)
            iconView.snp.makeConstraints({ (make) in
                make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(22.0))
                make.centerY.equalTo((cell?.contentView)!)
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(45.0), height: CYLayoutConstraintValue(45.0)))
            })
            
            
            // 加好友按钮
            let addFriendButton                             = UIButton(type: .custom)
            addFriendButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#42C099"), forState: .normal)
            addFriendButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#BFC0C0"), forState: .selected)
            addFriendButton.tag                             = 500
            addFriendButton.setTitleColor(UIColor.white, for: .normal)
            addFriendButton.setCornerRadius(CYLayoutConstraintValue(4.0))
            addFriendButton.titleLabel?.font                = CYLayoutConstraintFont(14.0)
            addFriendButton.titleLabel?.textAlignment       = .center
            addFriendButton.setTitle("加好友", for: .normal)
            addFriendButton.setTitle("已发送", for: .selected)
            addFriendButton.addTarget(self, action: #selector(addNewFriend(_:event:)), for: .touchUpInside)
            cell?.contentView.addSubview(addFriendButton)
            addFriendButton.snp.makeConstraints({ (make) in
                make.centerY.equalTo((cell?.contentView)!)
                make.right.equalTo(-CYLayoutConstraintValue(19.0))
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(75.0), height: CYLayoutConstraintValue(30.0)))
            })
            
            // 姓名
            let titleLabel                  = UILabel()
            titleLabel.tag                  = 200
            titleLabel.font                 = CYLayoutConstraintFont(16.0)
            titleLabel.textColor            = UIColor.colorWithHexString("#333333")
            cell?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(iconView.snp.right).offset(CYLayoutConstraintValue(15.0))
                make.top.equalTo((cell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(11.5))
                make.right.equalTo(addFriendButton.snp.left).offset(-CYLayoutConstraintValue(10.0))
            }
            
            // 子标题
            let subTitleLabel               = UILabel()
            subTitleLabel.tag               = 300
            subTitleLabel.font              = CYLayoutConstraintFont(14.0)
            cell?.contentView.addSubview(subTitleLabel)
            subTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo((titleLabel.snp.bottom)).offset(CYLayoutConstraintValue(5.0))
                make.left.right.equalTo(titleLabel)
            }
            
            
        }
        
        let contactModel                        = indexPath.section == 0 ? self.localContacts[indexPath.row] : self.recommendContacts[indexPath.row]
        
        let imageView                           = cell?.contentView.viewWithTag(100) as? UIImageView
        imageView?.kf.setImage(with: URL(string: (contactModel.avatar)), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)

        // 标题
        let label                               = cell?.contentView.viewWithTag(200) as? UILabel
        label?.text                             = contactModel.name
        
        let subLabel                            = cell?.contentView.viewWithTag(300) as? UILabel
        let desc                                = String(format: "%@ %@", contactModel.company,contactModel.company_position)
        
        subLabel?.text                          = desc
    
        let addFriendButton                     = cell?.contentView.viewWithTag(500) as! UIButton
        
        let isFriend                            = BKRealmManager.shared().customerUserIsFriendOrder(by: contactModel.uid)
        
        if isFriend {
            addFriendButton.setTitle("发消息", for: .normal)
        }

        // 是否向某人发送了加好友信息
        if let sendList = BKRealmManager.shared().querySendListModel(contactModel.uid) {
            addFriendButton.isSelected                  = sendList.isSend
        } else {
            addFriendButton.isSelected                  = false
        }
        
        
        return cell!
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(67.5)
    }
    func getContact(at indexPath : IndexPath) -> BKCustomersContact {
        var contatcModel: BKCustomersContact?
        if self.searchType == .searchLocalContact {
            contatcModel = self.localContacts[indexPath.row]
        } else {
            contatcModel = indexPath.section == 0 ? self.localContacts[indexPath.row] : self.recommendContacts[indexPath.row]
        }
        return contatcModel!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.textField.resignFirstResponder()
      
        let contatcModel = getContact(at: indexPath)
        
        let isFriend                            = BKRealmManager.shared().customerUserIsFriendOrder(by: contatcModel.uid)
        
        if isFriend {
            
            // 进入单聊
           EMIMHelper.shared().hy_chatRoom(withConversationChatter: (contatcModel.uid), soureViewController: self)
            
        } else {
            
            let userDetailViewController    = BKUserDetailViewController()
            userDetailViewController.userId = contatcModel.uid
            self.navigationController?.pushViewController(userDetailViewController, animated: true)
            
        }

        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && self.localContacts.count == 0 {
            return 0.0
        } else if (section == 1 && self.recommendContacts.count == 0) {
            return 0.0
        }
        return CYLayoutConstraintValue(40.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 && self.localContacts.count == 0 {
            return nil
        } else if (section == 1 && self.recommendContacts.count == 0) {
            return nil
        }
        
        var headView            = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headView")
        if (nil == headView) {
            
            headView            = UITableViewHeaderFooterView(reuseIdentifier: "headView")
            let label           = UILabel()
            label.textColor     = UIColor.colorWithHexString("#8E8E93")
            label.font          = CYLayoutConstraintFont(14.0)
            label.tag           = 100
            headView?.contentView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.left.equalTo((headView?.contentView.snp.left)!).offset(CYLayoutConstraintValue(15.0))
                make.top.bottom.right.equalTo((headView?.contentView)!)
            })
            
        }
        
        let label               = headView?.contentView.viewWithTag(100) as! UILabel
        label.text              = section == 0 ? (self.searchType == .searchLocalContact ? "我的人脉" : "搜索结果") : "可能感兴趣的人"
        label.textColor         = UIColor.gray
        
        return headView

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.separatorInset = UIEdgeInsets.zero
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
    }
    
}

// MARK: - 打招呼
extension BKSearchContactViewController : BKMakeCallViewControllerDelegate {
    
    func makeCall(with msg : String) {
         self.addFriendReqeust(self.userId ?? "", msg: msg)
    }
    
}
