//
//  BKUserDetailViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/4.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 用户详细资料
class BKUserDetailViewController: BKBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.setup()
        self.addHeadView()
        self.addFooterView()
        self.loadDatas()
        
    }
    var userId : String = ""  {
        didSet {
            self.userSelf = (KCustomAuthorizationToken.easemob_username == userId)
        }
    }
    var footerButton : UIButton?
    var userSelf : Bool                         = true
    var groupArray : [BKChatGroupModel]         = [BKChatGroupModel]() // 放社群信息的字典
    var dictArray : [[String : String]]? // 放手机号 职能的字典
    var contactImageButtons : [UIButton]? // 放人脉头像的数组
    lazy var tableView : UITableView           = {
        let tableView                          = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor              = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        tableView.delegate                     = self
        tableView.dataSource                   = self
        return tableView
    }()
    var isMyFriend : Bool                     = false
    var activitysArray : [String]             = [String]()
    var userContacts : [BKCustomersContact]   = [BKCustomersContact]()
    var headView : BKUserDetailHeadView?
    var userActivityImageButton : [UIButton]? // 放他的动态的图片数组
    fileprivate var userInfo : UserInfo?
    func setup() {
        
        
        self.view.backgroundColor               = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!).inset(UIEdgeInsetsMake(0.0, 0.0, (self?.userSelf)! ? 0.0 : 70.0, 0.0))
        }
        self.title                              = "详细资料"
        self.isMyFriend                         = BKRealmManager.shared().customerUserIsFriendOrder(by: userId)
        

    }
    
    var secrecyView : UIView = UIView()
    
    /// 添加头部视图
    func addHeadView() {
        
        self.headView                       = BKUserDetailHeadView.viewFromNib() as? BKUserDetailHeadView
        self.headView?.delegate             = self
        self.tableView.tableHeaderView      = self.headView
        self.headView?.snp.makeConstraints({[unowned self] (make) in
            make.top.left.equalTo(self.tableView)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(210.0)))
        })
        
        // 保密的视图
        self.tableView.addSubview(self.secrecyView)
        self.secrecyView.backgroundColor = UIColor.white
        self.secrecyView.isHidden        = true
        self.secrecyView.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.tableView.snp.top)!).offset(CYLayoutConstraintValue(220.0))
            make.left.equalTo((self?.tableView)!)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(195.0)))
        }
        
        let secrecyLockImageView : UIImageView = UIImageView()
        secrecyLockImageView.image             = UIImage(named: "secrecylock")
        self.secrecyView.addSubview(secrecyLockImageView)
        secrecyLockImageView.snp.makeConstraints {[weak self] (make) in
            make.centerX.equalTo((self?.secrecyView)!)
            make.top.equalTo((self?.secrecyView.snp.top)!).offset(CYLayoutConstraintValue(40.0))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(50.5), height: CYLayoutConstraintValue(51.5)))
        }
        
        // 保密的 label
        let secrecyLabel                        = UILabel()
        secrecyLabel.text                       = "由于对方的隐私设置你无法\n查看TA 的个人资料"
        secrecyLabel.textAlignment              = .center
        secrecyLabel.textColor                  = UIColor.colorWithHexString("#666666")
        secrecyLabel.numberOfLines              = 0
        secrecyLabel.font                       = CYLayoutConstraintFont(15.0)
        self.secrecyView.addSubview(secrecyLabel)
        secrecyLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo(secrecyLockImageView.snp.bottom).offset(CYLayoutConstraintValue(21.0))
            make.centerX.equalTo((self?.secrecyView)!)
        }
        
    }
    
    /// 添加底部的发送消息按钮
    func addFooterView() {
    
        guard !userSelf else {
            self.tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 30.0))
            return
        }

        let sendMessageButton                   = UIButton(type: .custom)
      
        sendMessageButton.setTitleColor(UIColor.white, for: .normal)
        sendMessageButton.backgroundColor       = UIColor.colorWithHexString("#18B091")
        sendMessageButton.layer.cornerRadius    = CYLayoutConstraintValue(4.0)
        sendMessageButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#42C099"), forState: .normal)
        sendMessageButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#BFC0C0"), forState: .selected)
        sendMessageButton.layer.masksToBounds   = true
        sendMessageButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        self.view.addSubview(sendMessageButton)
        sendMessageButton.snp.makeConstraints {[weak self] (make) in
            make.bottom.equalTo((self?.view.snp.bottom)!).offset(-CYLayoutConstraintValue(10.0))
            make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(20.0))
            make.right.equalTo((self?.view.snp.right)!).offset(-CYLayoutConstraintValue(20.0))
            make.height.equalTo(CYLayoutConstraintValue(50.0))
        }
        
        self.footerButton                           = sendMessageButton
        
        self.reloadFooterView()
        
    }
    
    func relaodDatas() {

        // 手机号和行业职能
        let mobile              = self.userInfo?.mobile ?? "保密" // 手机号码
        let industry : String   = (self.userInfo?.industry_function_items)! // 行业职能

        self.dictArray          = [
            ["title" : "手机号", "subTitle" : mobile],
            ["title" : "行业职能", "subTitle" : industry]
        ]
        
        // 人脉列表
        self.userContacts           = UnitTools.bk_RlmArrayAllObjects(rlmArray: (self.userInfo?.top_customer_friends)!, ojbType: BKCustomersContact())
        
        // 群组列表
        self.groupArray             = UnitTools.bk_RlmArrayAllObjects(rlmArray: (self.userInfo?.joined_chat_groups)!, ojbType: BKChatGroupModel())
        
        // 巴圈动态图片列表
        if self.userInfo?.recent_hub_images != nil {
            self.activitysArray     = (self.userInfo?.recent_hub_images)?.arrayValue() as! [String]
        }
        
        self.tableView.reloadData()
        
    }
    
    /// 刷新头部视图
    func reloadHeadView() {
        
        let userName                                = self.userInfo?.name
        let title                                   = self.userInfo?.company_position
        let company                                 = self.userInfo?.company
        let avatar                                  = self.userInfo?.avatar ?? ""
        self.headView?.nickNameLabel.text           = userName
        self.headView?.jobTitleLabel.text           = title
        self.headView?.companyLabel.text            = company
        self.headView?.avatarImageView.kf.setImage(with: URL(string : avatar), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        
        if userSelf {
            self.headView?.saveButton.setTitle("编辑", for: .normal)
            self.headView?.saveButton.setImage(nil, for: .normal)
        } else {
            
            self.headView?.saveButton.setTitle(nil, for: .normal)
            self.headView?.saveButton.setImage(UIImage(named:"chat_setting"), for: .normal)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(true,                                                                                                                        animated: true)
    }
    
    
    /// 点击了人脉的头像
    func contactButttonClick(_ btn :UIButton) {
        
        let contactModel                    = self.userContacts[btn.tag-100]
        let userDetailViewController        = BKUserDetailViewController()
        userDetailViewController.userId     = contactModel.uid
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
        
    }
 
    deinit {
        NJLog(self)
    }
    
}


// MARK: - 请求用户社群 人脉 和用户资料
extension BKUserDetailViewController {
   
    /// 通过 userId 查询用户资料
    func reqeustCustomerUserInfo(by userId : String) {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getOperationReqeust(baseURLPath + "customers/profile", params: ["customer_uid" : self.userId]  , success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json                        = success.value
            let profile                     = json["profile"]?.dictionary
            guard profile                   != nil else {
                UnitTools.addLabelInWindow("获取用户资料失败", vc: self)
                self?.navigationController?.popViewControllerAnimated(true, delay: 0.5)
                return
            }
            
            self?.userInfo              = UserInfo(with: profile!)
            
            let namecard_visible_scope  = self?.userInfo?.namecard_visible_scope ?? ""
            
            self?.reloadHeadView()
            // 可以查看自己的资料
            guard !(self?.userSelf)! else {
                self?.secrecyView.isHidden = true
                self?.relaodDatas()
                return
            }
            // 名片设置保密的不可查看
            guard !namecard_visible_scope.contains("保密") else {
                self?.secrecyView.isHidden = false
                self?.tableView.bringSubview(toFront: (self?.secrecyView)!)
                self?.reloadFooterView()
                return
            }
            // 是好友并且仅好友查看可以显示名片
            if namecard_visible_scope.contains("仅好友可见我的资料") && (self?.isMyFriend)! {
                self?.secrecyView.isHidden = true
                self?.reloadFooterView()
                self?.relaodDatas()
            } else if namecard_visible_scope.contains("所有人可见我的资料") {
                // 所有人可看资料时也可以查看资料
                self?.secrecyView.isHidden = true
                self?.reloadFooterView()
                self?.relaodDatas()
            } else {
                self?.tableView.bringSubview(toFront: (self?.secrecyView)!)
                self?.secrecyView.isHidden = false
                UnitTools.addLabelInWindow("资料不可查看", vc: self)
            }

            }) {[weak self] (failure) in
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow("获取用户资料失败", vc: self)
                self?.navigationController?.popViewControllerAnimated(true, delay: 0.5)
        }

    }
    
  
    func loadDatas() {
        
        guard !self.userId.isEmpty else {
            return
        }
        
        self.tableView.delayReload(with: 0.1)
        self.reqeustCustomerUserInfo(by: userId)

    }
    
    /// 发布动态
    func sendActivity() {
        
        let  composeViewController                 = BKComposeViewController()
        composeViewController.delegate             = self
        let nav                                    = BKNavigaitonController(rootViewController: composeViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKUserDetailViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            guard self.dictArray?.count != nil else {
                return 0
            }
            return (self.dictArray?.count)!
        } else if section == 2 {
            guard self.groupArray.count != 0 else {
                return 0
            }
            return self.groupArray.count > 5 ? 5 : self.groupArray.count
        } else if section == 3 {
            guard self.userContacts.count != 0 else {
                return 0
            }
        }else if section == 0 {
            return self.activitysArray.count == 0 ? ( userSelf ? 1 : 0 ) : 1
        }
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 手机号和行业只能
        if indexPath.section == 1 {
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
            if cell == nil {
                
                cell                                = UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
                cell?.textLabel?.font               = CYLayoutConstraintFont(17.0)
                cell?.textLabel?.textColor          = UIColor.colorWithHexString("#333333")
                cell?.detailTextLabel?.font         = CYLayoutConstraintFont(17.0)
                cell?.detailTextLabel?.textColor    = UIColor.colorWithHexString("#8F8F8F")
                cell?.selectionStyle                = .none
                
            }
            
            let dict                    = self.dictArray?[indexPath.row]
            cell?.textLabel?.text       = dict?["title"]
            
            let subTitle                = dict?["subTitle"]
            
            cell?.detailTextLabel?.text = subTitle
            
            return cell!
        } else if indexPath.section == 0 { // 他的动态
          
            var activityCell    = tableView.dequeueReusableCell(withIdentifier: "Activity")
            
            if nil == activityCell {
                
                activityCell                    = UITableViewCell(style: .default, reuseIdentifier: "Activity")
                activityCell?.selectionStyle    = .none
                
                weak var lastButton : UIButton?
                self.userActivityImageButton    = [UIButton]()
                for i in 0..<5 {
                    
                    let button                          = UIButton(type: .custom)
                    button.backgroundColor              = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
                    button.tag                          = i + 100
                    button.isUserInteractionEnabled     = false
                    activityCell?.contentView.addSubview(button)
                    button.snp.makeConstraints({ (make) in
                        make.size.equalTo(CGSize(width: CYLayoutConstraintValue(50.0), height: CYLayoutConstraintValue(50.0)))
                        make.centerY.equalTo((activityCell?.contentView)!)
                        button.layer.masksToBounds      = true
                        button.layer.cornerRadius       = CYLayoutConstraintValue(4.0)
                        if lastButton != nil {
                            make.left.equalTo((lastButton?.snp.right)!).offset(CYLayoutConstraintValue(6.0))
                        } else {
                            make.left.equalTo((activityCell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(21.0))
                        }
                    })
                    lastButton = button
                    self.userActivityImageButton?.append(button)
                    
                }
                
                // 发表动态的按钮
                let sendActivityButton : UIButton               = UIButton(type: .custom)
                sendActivityButton.backgroundColor              = UIColor.white
                sendActivityButton.layer.borderColor            = UIColor.colorWithHexString("#18B091").cgColor
                sendActivityButton.layer.borderWidth            = 0.5
                sendActivityButton.setTitle("发布第一个动态", for: .normal)
                sendActivityButton.setTitleColor(UIColor.colorWithHexString("#18B091"), for: .normal)
                sendActivityButton.titleLabel?.font             = CYLayoutConstraintFont(16.0)
                sendActivityButton.titleLabel?.textAlignment    = .center
                sendActivityButton.addTarget(self, action: #selector(sendActivity), for: .touchUpInside)
                sendActivityButton.isHidden                     = true
                sendActivityButton.tag                          = 1000
                activityCell?.contentView.addSubview(sendActivityButton)
                sendActivityButton.snp.makeConstraints({ (make) in
                    make.center.equalTo( (activityCell?.contentView)!)
                    make.size.equalTo(CGSize(width: CYLayoutConstraintValue(150.0), height: CYLayoutConstraintValue(35.0)))
                })
                
                
            }
            
            let count               = self.activitysArray.count >= 5 ? 5 : self.activitysArray.count
            for (_,button) in self.userActivityImageButton!.enumerated() {
                button.isHidden                         = true
            }
            
            for index in 0..<count {
                
                let button                              = self.userActivityImageButton?[index]
                let avatar                              = self.activitysArray[index]
                button?.isHidden                        = false
                button?.kf.setBackgroundImage(with: URL(string :avatar), for: .normal, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                
            }
            
            let button : UIButton                       = activityCell?.contentView.viewWithTag(1000) as! UIButton
            
            let isHidden                                = !(userSelf && count == 0)

            button.isHidden                             = isHidden

            return activityCell!
            
        } else if indexPath.section == 2 { // 加入社群
            
            var groupCell = tableView.dequeueReusableCell(withIdentifier: "Group")
            if groupCell == nil {
                
                groupCell                           = UITableViewCell(style: .default, reuseIdentifier: "Group")
                groupCell?.selectionStyle           = .none
                
                // 头像
                let imageView                       = UIImageView()
                imageView.image                     = KCustomerUserHeadImage
                imageView.tag                       = 100
                imageView.layer.cornerRadius        = CYLayoutConstraintValue(25.0)
                imageView.layer.masksToBounds       = true
                groupCell?.contentView.addSubview(imageView)
                imageView.snp.makeConstraints({ (make) in
                    make.size.equalTo(CGSize(width: CYLayoutConstraintValue(50.0), height: CYLayoutConstraintValue(50.0)))
                    make.centerY.equalTo((groupCell?.contentView)!)
                    make.left.equalTo(CYLayoutConstraintValue(18.0))
                })
                
                
                // 群名称
                let titleLabel                      = UILabel()
                titleLabel.textColor                = UIColor.colorWithHexString("#333333")
                titleLabel.font                     = CYLayoutConstraintFont(16.0)
                titleLabel.tag                      = 200
                groupCell?.contentView.addSubview(titleLabel)
                titleLabel.snp.makeConstraints({ (make) in
                    make.top.equalTo((groupCell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(12.0))
                    make.left.equalTo(imageView.snp.right).offset(CYLayoutConstraintValue(10.0))
                })
                
                let subTitleLabel                  = UILabel()
                subTitleLabel.textColor            = UIColor.colorWithHexString("#777777")
                subTitleLabel.font                 = CYLayoutConstraintFont(14.0)
                subTitleLabel.tag                  = 300
                groupCell?.contentView.addSubview(subTitleLabel)
                subTitleLabel.snp.makeConstraints({ (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(CYLayoutConstraintValue(9.0))
                    make.left.equalTo(imageView.snp.right).offset(CYLayoutConstraintValue(10.0))
                })
                
            }
            
            let chatGroup                       = self.groupArray[indexPath.row]
            let avatar                          = chatGroup.avatar ?? ""
            let imageView                       = groupCell?.contentView.viewWithTag(100) as! UIImageView
            imageView.kf.setImage(with: URL(string: avatar), placeholder:KChatGroupPlaceholderImage, options: nil, progressBlock: nil, completionHandler: nil)
            
            let titleLabel                      = groupCell?.contentView.viewWithTag(200) as! UILabel
            titleLabel.text                     = chatGroup.groupname
            
            let subTitleLabel                   = groupCell?.contentView.viewWithTag(300) as! UILabel
            subTitleLabel.text                  = String(format: "%d人", chatGroup.member_count)
            
            return groupCell!
            
        } else {
            
            // 人脉的cell
            var contactCell            = tableView.dequeueReusableCell(withIdentifier: "contactCell")
            if nil == contactCell    {
                
                contactCell    = UITableViewCell(style: .default, reuseIdentifier: "contactCell")
                contactCell?.selectionStyle    = .none
                self.contactImageButtons       = [UIButton]()
                weak var lastButton : UIButton?
                for i in 0..<5 {
                    
                    let button                  = UIButton(type: .custom)
                    button.isHidden             = true
                    button.isUserInteractionEnabled = false
                    button.setBackgroundImage(KCustomerUserHeadImage, for: .normal)
                    button.tag                  = i + 100
                    contactCell?.contentView.addSubview(button)
                    button.snp.makeConstraints({ (make) in
                        make.size.equalTo(CGSize(width: CYLayoutConstraintValue(50.0), height: CYLayoutConstraintValue(50.0)))
                        make.centerY.equalTo((contactCell?.contentView)!)
                        button.layer.masksToBounds  = true
                        button.layer.cornerRadius   = CYLayoutConstraintValue(25.0)
                        if lastButton != nil {
                            make.left.equalTo((lastButton?.snp.right)!).offset(CYLayoutConstraintValue(6.0))
                        } else {
                            make.left.equalTo((contactCell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(18.0))
                        }
                    })
                    
                    lastButton                  = button
                    self.contactImageButtons?.append(button)
                }
              
                
            }
            let count   = self.userContacts.count >= 5 ? 5 : self.userContacts.count
            for (_,button) in self.contactImageButtons!.enumerated() {
               button.isHidden = true
            }
            
            for index in 0..<count {
                
                let button                              = self.contactImageButtons?[index]
                let contact                             = self.userContacts[index]
                button?.isHidden                        = false
                button?.kf.setBackgroundImage(with: URL(string : contact.avatar), for: .normal, placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
                
            }

            return contactCell!
        }
      
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CYLayoutConstraintValue(68.0)
        } else if indexPath.section == 2 || indexPath.section == 3 {
            return CYLayoutConstraintValue(70.0)
        }
        return CYLayoutConstraintValue(44.0)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section) {
        case 0 :
            seeUserBayeCircle()
            break
            
        case 2 :
            
            // 群组详情页面
            let chatGroupModel                       = self.groupArray[indexPath.row]
            let isJoinGroup                          = BKRealmManager.shared().cusetomerUserIs(inChatGroup: chatGroupModel.groupid!)
            guard !isJoinGroup else {
                
                EMIMHelper.shared().hy_chatRoom(withConversationChatter: chatGroupModel.groupid!, soureViewController: self)
                return
            }
            
            // 群组详情页面
            let groupDetailViewController           = BKGroupDetailsViewController()
            groupDetailViewController.groupId       = chatGroupModel.groupid
            self.navigationController?.pushViewController(groupDetailViewController, animated: true)
            
            break
        case 3 :
            seeUserContacts()

            break
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         if (section == 2 && self.groupArray.count == 0) {
            return 0.0001
        }
        
        return section == 1 ? CYLayoutConstraintValue(23.0) : CYLayoutConstraintValue(68.0)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 2 && self.groupArray.count > 5) {
            return CYLayoutConstraintValue(45.0)
        }
        return 0.001
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.separatorInset = UIEdgeInsets.zero
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.separatorInset = UIEdgeInsets.zero
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            return nil
        } else if (section == 3 && self.userContacts.count == 0) {
                return nil
        } else if (section == 2 && self.groupArray.count == 0) {
            return nil
        }

        var headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeadView")
        if headView == nil {
            headView = UITableViewHeaderFooterView(reuseIdentifier: "HeadView")
            // 背景
            let view                        = UIView()
            view.backgroundColor            = UIColor.white
            headView?.contentView.addSubview(view)
            view.snp.makeConstraints({ (make) in
                make.edges.equalTo((headView?.contentView)!).inset(UIEdgeInsetsMake(CYLayoutConstraintValue(23.0), 0.0,0.0, 0.0))
            })
            
            // 标题
            let titleLabel                  = UILabel()
            titleLabel.tag                  = 100
            titleLabel.textColor            = UIColor.colorWithHexString("#333333")
            titleLabel.font                 = CYLayoutConstraintFont(17.0)
            view.addSubview(titleLabel)
            titleLabel.snp.makeConstraints({ (make) in
                make.top.bottom.equalTo(view)
                make.left.equalTo(view.snp.left).offset(15.0)
            })
            
            // 右边跳转按钮
            let rightArrow                  = UIImageView()
            rightArrow.tag                  = 200
            rightArrow.image                = UIImage(named: "right_nextarrow")
            view.addSubview(rightArrow)
            rightArrow.snp.makeConstraints({ (make) in
                make.right.equalTo(view.snp.right).offset(-CYLayoutConstraintValue(10.0))
                make.centerY.equalTo(view)
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(8.0), height: CYLayoutConstraintValue(13.0)))
            })
            
            
        }
        
        let titleLabel                      = headView?.contentView.viewWithTag(100) as! UILabel
        
        let chatGroupCount                  = self.groupArray.count
        titleLabel.text                     = (section == 0) ? (userSelf ? "我的巴圈" : "他的巴圈") : (section == 2) ? "加入部落 (\(chatGroupCount))" :  (userSelf ? "我的人脉" : "他的人脉")
        
        let rightView                       = headView?.contentView.viewWithTag(200) as! UIImageView
        rightView.isHidden                  = section == 2
        
        if (titleLabel.text?.contains("人脉"))! {
            headView?.tag = 1000
        } else if (titleLabel.text?.contains("巴圈"))! {
            headView?.tag = 2000
        } else if (titleLabel.text?.contains("部落"))! {
            headView?.tag = 3000
        }
        
        headView?.addTarget(self, action: #selector(sectionHeadViewClick(_:)))

        return headView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard section == 2 else {
            return nil
        }
        
        guard self.groupArray.count > 5 else {
            return nil
        }
        
        var footView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footView")
        
        if footView == nil {
            
            footView                = UITableViewHeaderFooterView(reuseIdentifier: "footView")
            let button              = UIButton(type: .custom)
            button.tag              = 101
            button.backgroundColor  = UIColor.white
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
            button.addTarget(self, action: #selector(userChatgroupList(_:)), for: .touchUpInside)
            button.setTitleColor(UIColor.colorWithHexString("#666666"), for: .normal)
            footView?.contentView.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.edges.equalTo((footView?.contentView)!)
            })
            
        }
        
        let button              = footView?.contentView.viewWithTag(101) as! UIButton
        button.setTitle("查看全部（\(self.groupArray.count)）", for: .normal)
        
        return footView
    }
    
    /// 用户群组列表
    func userChatgroupList(_ btn :UIButton) {
        
        let chatGroups              = BKUserChatGroupsViewController()
        chatGroups.chatgroupArray   = self.groupArray
        self.navigationController?.pushViewController(chatGroups, animated: true)
        
    }
    
    /// 查看人脉
    func seeUserContacts() {
        
        // 查看人脉
        let userContactViewController          = BKAddGroupMemberViewController()
        userContactViewController.displayType  = .detail
        userContactViewController.userId       = self.userId
        userContactViewController.title        = userSelf ? "我的人脉" : "他的人脉"
        userContactViewController.delegate     = self
        let nav                                = BKNavigaitonController(rootViewController: userContactViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
    /// 点击了区的headVIew
    func sectionHeadViewClick(_ tap : UITapGestureRecognizer) {
    
        // 查看人脉
        if tap.view?.tag == 1000 {
            seeUserContacts()
        } else if tap.view?.tag == 2000 {
           seeUserBayeCircle()
        }
    
    }
    
    /// 查看用户巴圈
    func seeUserBayeCircle() {
        
        guard !self.userId.isEmpty else {
            UnitTools.addLabelInWindow("查看他人动态失败", vc: self)
            return
        }
        
        // 查看他的动态页面
        let mineDynamicViewController               = BKMineDynamicStateViewController()
        mineDynamicViewController.userId            = self.userId
        self.navigationController?.pushViewController(mineDynamicViewController, animated: true)
        
    }
}

// MARK: - BKUserDetailHeadViewDelegate
extension BKUserDetailViewController : BKUserDetailHeadViewDelegate {
    
    /// 点击了返回的按钮
    func userDetailHeadViewDidSelectBackAction(_ headView: BKUserDetailHeadView) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    /// 点击了右侧的编辑资料按钮
     func userDetailHeadViewDidSelectEditingInfoAction(_ headView :BKUserDetailHeadView)  {
        
        if userSelf { // 自己名片可以编辑个人资料
            
            let editingBusinessCardVC           = BKEditingBusinessCardViewController()
            editingBusinessCardVC.leftTitle     = "编辑资料"
            self.navigationController?.pushViewController(editingBusinessCardVC, animated: true)
            
        } else { // 他人资料可以删除好友
            
            let chatSettingViewController                   = BKChatSettingViewController()
            chatSettingViewController.leftTitle             = "聊天设置"
            chatSettingViewController.userId                = self.userId
            chatSettingViewController.needCleanChatHistory  = false
            self.navigationController?.pushViewController(chatSettingViewController, animated: true)
            
        }
    }
    
    /// 点击了头像
    func userDetailHeadViewDidSelectAvatarImageView(_ headView: BKUserDetailHeadView) {
        
        let vc                  = CommodityImagesDetailViewController()
        let current_position    = 0
        let images              = self.userInfo?.avatar
        guard images            != nil else {
            return
        }
        
        vc.commodityImageArray  = [images!]
        let index               = current_position
        vc.currentPage          = index
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
}

//MARK: 添加好友和发送消息

extension BKUserDetailViewController {
    
    func sendMessage() {
        
        if isMyFriend {
            
            EMIMHelper.shared().hy_chatRoom(withConversationChatter: self.userId, soureViewController: self)
            
        } else {
            
            self.showAddFreinedAlertController(userId)
            
        }
        
        
    }
    
    /// 显示说点什么
    func showAddFreinedAlertController(_ userId : String) {
    
        self.userId                                 = userId
        let makeCallViewController                  = BKMakeCallViewController()
        makeCallViewController.leftTitle            = "好友验证"
        makeCallViewController.delegate             = self
        makeCallViewController.placeHolderString    = "你好，我是巴爷汇的\(BK_UserInfo.name)，请求添加你为好友！"
        let nav                                     = BKNavigaitonController(rootViewController: makeCallViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
    /// 添加好友的请求
    func addFriendReqeust(_ uid : String, msg : String) {
        
        BKNetworkManager.postReqeust(baseURLPath + "customer_friends/add", params: ["customer_uid" : uid,"message" : msg], success: {[weak self] (success) in
            
            let return_code         = success.value["return_code"]?.intValue ?? 0
            let return_message      = success.value["return_message"]?.stringValue ?? "请求加好友失败"
            if return_code != 200 {
                UnitTools.addLabelInWindow(return_message, vc: self)
                return
            }
            
            UnitTools.addLabelInWindow("发送添加好友申请成功", vc: self)
            self?.reloadFooterView()
            
        }) {[weak self] (failure) in
            
            UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
            
        }

        
        
    }

    
    /// 刷新 footerView 的显示内容
    func reloadFooterView() {
        
        guard self.userInfo != nil else {
            self.footerButton?.isHidden = true
            return
        }
        
        self.footerButton?.isHidden           = userSelf
        self.headView?.saveButton.isHidden    = !(self.isMyFriend)

        // 判断是否是好友
        if self.isMyFriend  {
            
            self.footerButton?.setTitle("发消息", for: .normal)
            
        } else {
            
            // 是否向某人发送了加好友信息
            var isSendReqeust = false
            if let sendModel = BKRealmManager.shared().querySendListModel(self.userId) {
                self.footerButton?.setTitle("已发送", for: .normal)
                isSendReqeust = sendModel.isSend
            } else {
                self.footerButton?.setTitle("加为好友", for: .normal)
            }

            self.footerButton?.isSelected                  = isSendReqeust
        }
        
    }
}

// MARK: - BKAddGroupMemberViewControllerDelegate
extension BKUserDetailViewController : BKAddGroupMemberViewControllerDelegate ,BKMakeCallViewControllerDelegate , BKComposeViewControllerDelegate {
    
    // 查看用户资料详情
    func userDetail(_ customer: BKCustomersContact, viewController: BKAddGroupMemberViewController) {
        
        let userDetailViewController        = BKUserDetailViewController()
        userDetailViewController.userId     = customer.uid
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
        
    }
    
    /// 打招呼成功后的回调
    func makeCall(with msg : String) {
        self.addFriendReqeust(self.userId , msg: msg)
    }
    
    /// 发帖成功之后刷新 UI
    func postActivitySuccess() {
       reqeustCustomerUserInfo(by: userId)
    }
    
}

