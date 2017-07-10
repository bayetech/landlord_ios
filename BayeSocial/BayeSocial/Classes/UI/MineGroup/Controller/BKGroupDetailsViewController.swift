
//
//  BKGroupDetailsViewController.swift
//  BayeSocial
//
//  Created by dzb on 2016/12/14.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON

/// 查看群资料的页面
class BKGroupDetailsViewController: BKBaseViewController  {

    open var groupId : String?
    var tableView: UITableView              = UITableView(frame: CGRect.zero, style: .plain)
    var groupModel : BKChatGroupModel? {
        didSet {
            groupId = groupModel?.groupid
        }
    }
    var groupLabel : UILabel?
    var groupMembers : [BKCustomersContact]?
    var datas : [[[String : String]]]       =  [[[String : String]]]()
    var descRowHeight : CGFloat             = 0.0
    var groupMembersView : [UIImageView]    = [UIImageView]()
    var joinButton : UIButton               = UIButton()
    var isVerifyGroup : Bool                = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addHeadView()
        
        if self.groupModel != nil {
            requestGroupInfo()
            setup()
        } else {
            requestGroupInfo()
            reqeustChatgroupDetails()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setup() {
        
        self.view.backgroundColor           = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        self.tableView.backgroundColor      = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        
        let sectionOne          = ["title" : "群分类","subTitle" : (self.groupModel?.category)!]
        let sectionTwo          = ["title" : "群成员","subTitle" : ""]
        let sectionThree        = ["title" : "创建时间","subTitle" : "2016-09-17"]
        self.datas              = [[sectionOne],[sectionTwo],[sectionThree]]
        //  计算群介绍的 desc 高度
        var height              = (self.groupModel?.desc)!.getTextSize(CYLayoutConstraintFont(15.0), restrictWidth: KScreenWidth-30.0).height
        height+=54.0
        descRowHeight           = height
        
    }
    
    func addHeadView() {
        
        self.view.addSubview(self.tableView)
        tableView.delegate                     = self
        tableView.dataSource                   = self
        tableView.tableFooterView                   = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 30.0))
        tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!).inset(UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0))
        }
        
        let headView                                = UIImageView()
        headView.frame                              = CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(230.0))
        headView.isUserInteractionEnabled           = true
        headView.image                              = UIImage(named: "chatgroup_background")
        self.tableView.tableHeaderView              = headView
        
        
        // 返回按钮
        let backButton                              = BKAdjustButton()
        backButton.setImage(UIImage(named:"back_white"), for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        backButton.frame                            = CGRect(x: CYLayoutConstraintValue(10.0), y: CYLayoutConstraintValue(36.0), width: 30.0, height: 30.0)
        backButton.setImageViewSizeEqualToCenter(CGSize(width: CYLayoutConstraintValue(13.0), height: CYLayoutConstraintValue(20.0)))
        headView.addSubview(backButton)

        // 群名称
        groupLabel                                  = UILabel()
        groupLabel?.font                            = CYLayoutConstraintFont(28.0)
        groupLabel?.text                            = self.groupModel?.groupname
        groupLabel?.textColor                       = UIColor.white
        headView.addSubview(self.groupLabel!)
        groupLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo(headView.snp.left).offset(CYLayoutConstraintValue(18.0))
            make.bottom.equalTo(headView.snp.bottom).offset(-CYLayoutConstraintValue(10.0))
        })

        // 申请加入的按钮
        view.addSubview(self.joinButton)
        joinButton.frame                            = CGRect(x: 0.0, y: KScreenHeight-50.0, width: KScreenWidth, height: 50.0)
        joinButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#39BBA1"), forState: .normal)
        joinButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#BFC0C0"), forState: .selected)
        joinButton.titleLabel?.font                 = UIFont.systemFont(ofSize: 16.0)
        joinButton.setTitleColor(UIColor.white, for: .normal)
        joinButton.titleLabel?.textAlignment        = .center
        joinButton.setTitle("申请加入", for: .normal)
        joinButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#BFC0C0"), forState: .selected)
        joinButton.addTarget(self, action: #selector(joinGroupClick(_:)), for: .touchUpInside)

        // 是否已经发送了请求
        if let sendListModel = BKRealmManager.shared().querySendListModel(self.groupId!) {
            self.setupJoinButtonState(sendListModel.isSend)
        } else {
            self.setupJoinButtonState(false)
        }
        
        tableView.delayReload(with: 0.01)

    }
    
 
    func back() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
 
    /// 请求群详情资料
    func requestGroupInfo() {

        EMClient.shared().groupManager.getGroupSpecificationFromServer(byID: self.groupId!, includeMembersList: true) {[weak self] (group, error) in
            guard error == nil else  {
                UnitTools.addLabelInWindow("查看群组详情信息失败!", vc: self)
                return
            }
            guard group != nil else {
                UnitTools.addLabelInWindow("查看群组详情信息失败!", vc: self)
                return
            }
            let members                 = group!.members
            var membersUids : String    = "\((group?.owner)!)"
            if members  != nil {
               let otherMembers         = UnitTools.arrayTranstoString(members as! [String])
                membersUids             = membersUids + ",\(otherMembers)"
            }
            self?.reqeustGroupMembers(membersUids)
        }
      
        
    }
    
    /// 请求群组详情根据 groupId
    func reqeustChatgroupDetails() {
        
        BKNetworkManager.getReqeust(KURL_MineJoinChat_groupsApi + "/\(self.groupId!)", params: nil, success: {[weak self] (success) in
            
            let chat_group = success.value["chat_group"]?.dictionary
            guard chat_group != nil  else {
                UnitTools.addLabelInWindow("获取群组详情失败", vc: self)
                return
            }
            
            self?.groupModel = BKChatGroupModel(by: JSON(chat_group!))
            
            self?.setup()
            
        }) {[weak self] (failure) in
            UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
        }
        
    }

    /// 获取群成员列表信息
    fileprivate func reqeustGroupMembers(_ uids : String) {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        AppDelegate.appDelegate().requestGroupMembers(by: self.groupId!) {[weak self] (customers) in
            HUD.hide(animated: true)
            self?.groupMembers  = customers
            self?.tableView.reloadData()
        }
        
    }
    
    deinit {
        NJLog(self)
    }
    
    
}

// MARK: - UITableViewDelegate , UITableViewDataSource
extension BKGroupDetailsViewController : UITableViewDelegate , UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.groupModel != nil else {
            return 0
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            guard self.groupMembers != nil else {
                return 1
            }
        } else if section == 2 {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (indexPath.row == 0) {
            
            var normalCell = tableView.dequeueReusableCell(withIdentifier: "normalCell")
            if normalCell == nil {
                normalCell                      = UITableViewCell(style: .value1, reuseIdentifier: "normalCell")
                normalCell?.selectionStyle      = .none
                
            }
            
            let dict                                = self.datas[indexPath.section][indexPath.row]
            let attributedString                    = NSMutableAttributedString(string: dict["title"]!, attributes: [NSFontAttributeName : CYLayoutConstraintFont(16.0),NSForegroundColorAttributeName : UIColor.colorWithHexString("#333333")])
            if indexPath.section == 1 {
                let membersCount = self.groupMembers?.count ?? 0
                attributedString.append(NSAttributedString(string: " \(membersCount) / \((self.groupModel?.maxusers)!)", attributes: [NSForegroundColorAttributeName : UIColor.colorWithHexString("#FAB66F")]))
            }
            normalCell?.textLabel?.attributedText   = attributedString;
            
            if indexPath.section                    == 2 {
                
                // 时间日期格式化
                normalCell?.detailTextLabel?.text     = Date.dateFormatterTimeInterval(TimeInterval((self.groupModel?.created_at)!), tiemFormatter: "YYYY-MM-dd")
                
            } else {
                normalCell?.detailTextLabel?.text     = dict["subTitle"]
            }
            
            return normalCell!
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            
            var groupDescCell   = tableView.dequeueReusableCell(withIdentifier: "descCell")
            if groupDescCell == nil {
                groupDescCell                   = UITableViewCell(style: .default, reuseIdentifier: "descCell")
                groupDescCell?.selectionStyle   = .none
                
                let titleLabel                  = UILabel()
                titleLabel.frame                = CGRect(x: 15.0, y: 11.0, width: KScreenWidth-30.0, height: 22.0)
                titleLabel.textColor            = UIColor.colorWithHexString("#333333")
                titleLabel.font                 = CYLayoutConstraintFont(16.0)
                titleLabel.text                 = "群介绍"
                groupDescCell?.contentView.addSubview(titleLabel)
                
                let descLabel                   = UILabel()
                descLabel.textColor             = UIColor.colorWithHexString("#666666")
                descLabel.font                  = CYLayoutConstraintFont(15.0)
                descLabel.tag                   = 100
                groupDescCell?.contentView.addSubview(descLabel)
                descLabel.snp.makeConstraints({ (make) in
                    make.edges.equalTo((groupDescCell?.contentView)!).inset(UIEdgeInsetsMake(42.0, 15.0, 10.0, 15.0))
                })
                
            }
            
            let descLabel                       = groupDescCell?.contentView.viewWithTag(100) as! UILabel
            descLabel.text                      = self.groupModel?.desc
            
            return groupDescCell!
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            
            var groupMembersCell   = tableView.dequeueReusableCell(withIdentifier: "groupMembersCell")
            if groupMembersCell == nil {
                groupMembersCell                    = UITableViewCell(style: .default, reuseIdentifier: "groupMembersCell")
                groupMembersCell?.selectionStyle    = .none
                groupMembersCell?.accessoryType     = .disclosureIndicator
                
                var lastImageView : UIImageView?
                for i in 0..<5 {
                    let imageView                       = UIImageView()
                    imageView.image                     = KCustomerUserHeadImage
                    imageView.setCornerRadius(20.0)
                    groupMembersCell?.contentView.addSubview(imageView)
                    imageView.snp.makeConstraints({ (make) in
                        make.top.equalTo((groupMembersCell?.contentView.snp.top)!).offset(11.0)
                        if lastImageView != nil {
                            make.left.equalTo((lastImageView?.snp.right)!).offset(CYLayoutConstraintValue(10.0))
                        } else {
                            make.left.equalTo((groupMembersCell?.contentView.snp.left)!).offset(15.0)
                        }
                        make.size.equalTo(CGSize(width: 40.0, height: 40.0))
                    })
                    
                    lastImageView = imageView
                    
                    // 姓名 label
                    let nameLabel                          = UILabel()
                    nameLabel.text                         = "董招兵"
                    nameLabel.font                         = UIFont.systemFont(ofSize: 14.0)
                    nameLabel.textAlignment                = .center
                    nameLabel.tag                          = i+100
                    nameLabel.textColor                    = UIColor.colorWithHexString("#979797")
                    groupMembersCell?.contentView.addSubview(nameLabel)
                    nameLabel.snp.makeConstraints({ (make) in
                        make.top.equalTo(imageView.snp.bottom).offset(6.0)
                        make.centerX.equalTo(imageView)
                        make.width.equalTo(50.0)
                    })
                    // 增加群主标签
                    if i == 0 {
                        // 群主的 label
                        let groupOwnerLabel                          = UILabel()
                        groupOwnerLabel.text                         = "酋长"
                        groupOwnerLabel.setCornerRadius(2.0)
                        groupOwnerLabel.font                         = UIFont.systemFont(ofSize: 8.0)
                        groupOwnerLabel.textAlignment                = .center
                        groupOwnerLabel.textColor                    = UIColor.white
                        groupOwnerLabel.backgroundColor              = UIColor.RGBColor(57.0, green: 187.0, blue: 161.0)
                        groupMembersCell?.contentView.addSubview(groupOwnerLabel)
                        groupOwnerLabel.snp.makeConstraints({ (make) in
                            make.bottom.right.equalTo(imageView)
                            make.size.equalTo(CGSize(width: 18.0, height: 12.0))
                        })
                    }
                    
                    self.groupMembersView.append(imageView)
                }
            }
            
            for (idx,imageView) in self.groupMembersView.enumerated() {
                
                let nameLabel          = groupMembersCell?.viewWithTag(idx+100) as! UILabel
                if idx < (self.groupMembers?.count)! {
                    
                    let user           = self.groupMembers?[idx]
                    imageView.isHidden = false
                    let avatar         = user?.avatar ?? ""
                    imageView.kf.setImage(with: URL(string : avatar), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
                    
                    nameLabel.text     = user?.name
                    
                } else {
                    imageView.isHidden = true
                }
                nameLabel.isHidden     = imageView.isHidden;
            }
            
            
            return groupMembersCell!
        }
        
        
        return UITableViewCell()
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 1 {
            return CGFloat(descRowHeight)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            return 100.0
        }
        
        return CYLayoutConstraintValue(44.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0001 : CYLayoutConstraintValue(12.0)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset     = UIEdgeInsets.zero
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 1 {
            
            let groupMembersViewController            = BKAddGroupMemberViewController()
            groupMembersViewController.displayType    = .detail
            groupMembersViewController.userContacts   = self.groupMembers ?? [BKCustomersContact]()
            groupMembersViewController.title          = "群成员"
            groupMembersViewController.delegate       = self
            let nav                                   = BKNavigaitonController(rootViewController: groupMembersViewController)
            self.present(nav, animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.separatorInset   = UIEdgeInsets.zero
    }

}

// MARK: - BKMakeCallViewControllerDelegate
extension BKGroupDetailsViewController : BKMakeCallViewControllerDelegate , BKAddGroupMemberViewControllerDelegate {
    
    /// 填完验证信息
    func makeCall(with msg: String) {
        self.addApplyJoinGroupReqeust(self.groupId ?? "", msg:msg)
    }
    
    /// 调用环信申请入群的接口
    
    func addApplyJoinGroupReqeust(_ uid : String,msg : String) {
        
        // 进群需要验证
        EMClient.shared().groupManager.request(toJoinPublicGroup: uid, message: msg) {[weak self] (group, error) in
            
            if group != nil {
                
                let sendListModel       = BKSendList(uid: uid, account: easemob_username, type: .group, isSend: true)
                BKRealmManager.shared().insert(sendListModel)
                self?.setupJoinButtonState(true)
                UnitTools.delay(0.3, closure: { () in
                    UnitTools.addLabelInWindow("发送加部落申请成功", vc: self)
                })
            } else {
                
                UnitTools.addLabelInWindow("发送加部落申请失败", vc: self)
                
            }

        }
        
        
    }
    
    /// 申请加入群组
    func joinGroupClick(_ btn : UIButton) {
        
        self.isVerifyGroup      = (groupModel?.is_approval)!
        if self.isVerifyGroup {
            
            self.showAddFreinedAlertController(self.groupId!)
        
        } else {
            
            EMClient.shared().groupManager.joinPublicGroup(self.groupId!, completion: {[weak self] (group, error) in
                if error != nil {
                    UnitTools.addLabelInWindow("发送申请失败", vc: self)
                    NJLog(error?.errorDescription)
                    return
                }
                
                let sendListModel       = BKSendList(uid: group?.groupId, account: easemob_username, type: .group, isSend: true)
                BKRealmManager.shared().insert(sendListModel)
                self?.setupJoinButtonState(true)
                UnitTools.delay(0.3, closure: {[weak self] () in
                    UnitTools.addLabelInWindow("发送加部落申请成功", vc: self)
                })
                
            })
        }
        
        
    }
    
    /// 设置申请加入按钮的状态显示
    func setupJoinButtonState(_ state : Bool) {
        self.joinButton.isSelected                 = state
    }
    
    /// 显示说点什么
    func showAddFreinedAlertController(_ groupId : String) {
        
        self.groupId                                = groupId
        let makeCallViewController                  = BKMakeCallViewController()
        makeCallViewController.delegate             = self
        makeCallViewController.leftTitle            = "部落验证"
        if self.groupModel?.groupname != nil {
            makeCallViewController.placeHolderString    = "你好，我是巴爷汇的\(BK_UserInfo.name)，请求加入  \((self.groupModel?.groupname)!)！"
        } else {
            makeCallViewController.placeHolderString    = "你好，我是巴爷汇的\(BK_UserInfo.name)，请求加入你的部落！"
        }
        let nav                                     = BKNavigaitonController(rootViewController: makeCallViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
    
    /// 查看用户详情资料
    
    func userDetail(_ customer: BKCustomersContact, viewController: BKAddGroupMemberViewController) {
        
        let userDetailViewController        = BKUserDetailViewController()
        userDetailViewController.userId     = customer.uid
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
        
    }
    
}
