//
//  BKGroupApplyViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/11.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD


/// 群组通知的控制器

class BKGroupApplyViewController: BKBaseViewController {
    
    lazy var tableView : UITableView = {
        let tableView                   = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor       = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        tableView.delegate              = self
        tableView.dataSource            = self
        return tableView
    }()
    var userContacts : [String : BKCustomersContact] =  [String : BKCustomersContact]()
    var applyModels : [BKApplyGroupModel]           = [BKApplyGroupModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title                      = "部落通知"
        self.setup()
        BKRealmManager.shared().readAllGroupApplays()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDatas()

    }
    
    func setup() {
    
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!).inset(UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0))
        }
        
    }
    
    func loadDatas() {
        
        self.applyModels    = BKRealmManager.shared().queryAllGroupApplys()

    }
    
    /// 请求用户所有资料的集合
    func requestUserInfo(_ userIds : String) {
        guard !userIds.isEmpty else {
            return
        }
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getReqeust(KURL_Customer_friends, params: ["uids" : userIds], success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json                = success.value
            let customers           = json["customers"]?.arrayValue
            let error_code          = json["error_code"]?.intValue
            DispatchQueue.main.async(execute: {
                guard error_code == nil else {
                    UnitTools.addLabelInWindow("获取联系人失败!", vc:nil)
                    return
                }
                guard customers != nil else {
                    UnitTools.addLabelInWindow("获取联系人失败!", vc:nil)
                    return
                }
            })
            DispatchQueue.global().async(execute: {
                let array = BKCustomersContact.customersWithJSONArray(customers!)
                for (_,item) in array.enumerated() {
                    self?.userContacts[item.uid] = item
                }
                DispatchQueue.main.async(execute: {
                    self?.tableView.reloadData()
                })
            })

        }) { (failure) in
            
            
        }
        
        
    }

    //MARK: 同意加群 分群主邀请入群 和 群主同意别人加群申请
    /// 接受加群的申请
    func acceptButtonClick( _ btn :UIButton,event : Any) {
        let indexPath = btn.indexPath(at: self.tableView, forEvent: event)
        if indexPath != nil {
            let applyModel  = self.applyModels[indexPath!.row]
            HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
            if applyModel.applyType == .joinGroup {
                self.acceptUserJoinGroup(at: indexPath!, applyModel)
            } else if applyModel.applyType == .InviteGroup {
                self.userAcceptJoinGroup(at: indexPath!, applyModel)
            }
        }
    }
    
    /// 群主同意用户加群申请 群管理员权限
    func acceptUserJoinGroup(at indexPath:IndexPath , _ applyModel  : BKApplyGroupModel) {
        
        let error  = EMClient.shared().groupManager.acceptJoinApplication(applyModel.groupId, applicant: applyModel.customer_uid)
        HUD.hide(animated: true)
        if error != nil {
            UnitTools.addLabelInWindow("接受加部落申请失败", vc: self)
        } else {
            UnitTools.addLabelInWindow("接受加部落申请成功", vc: self)
            self.applyModels.remove(at: (indexPath.row))
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
    }
    /// 用户同意加入群聊 用户权限
    func userAcceptJoinGroup(at indexPath:IndexPath , _ applyModel  : BKApplyGroupModel) {

        EMClient.shared().groupManager.acceptInvitation(fromGroup: applyModel.groupId, inviter: applyModel.customer_uid) {[weak self] (group, error) in
            HUD.hide(animated: true)
            
            if error != nil {
                
                UnitTools.addLabelInWindow("接受加部落邀请申请失败", vc: self)
                
            } else {
                
                BKRealmManager.shared().deleteGroupApplay(applyModel.customer_uid)
                UnitTools.addLabelInWindow("接受加部落邀请申请成功", vc: self)
                self?.applyModels.remove(at: (indexPath.row))
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                
            }
            
        }
        
        
    }
    
    //MARK: 拒绝加群 分群主拒绝别人入群 和 自己拒绝别人的加群邀请
    /// 拒绝加群的申请
    func declineButtonClick( _ btn :UIButton,event : Any) {
        
        let indexPath = btn.indexPath(at: self.tableView, forEvent: event)
        if indexPath != nil {
            let applyModel  = self.applyModels[indexPath!.row]
            HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
            if applyModel.applyType == .joinGroup {
                self.declineUserJoinGroup(at: indexPath!, applyModel)
            } else if applyModel.applyType == .InviteGroup {
                self.userDeclineJoinGroup(at: indexPath!, applyModel)
            }
        }
        
    }
    /// 用户主动拒绝加入群聊 用户权限
    func userDeclineJoinGroup(at indexPath:IndexPath , _ applyModel  : BKApplyGroupModel) {
        
        NJLog(applyModel.customer_uid)
        NJLog(applyModel.groupId)

        let error  = EMClient.shared().groupManager.declineInvitation(fromGroup: applyModel.groupId, inviter:applyModel.customer_uid, reason: "")
        
        HUD.hide(animated: true)

        if error != nil {
            
            UnitTools.addLabelInWindow("拒绝邀请加部落申请失败", vc: self)
        
        } else {

            BKRealmManager.shared().deleteGroupApplay(applyModel.customer_uid)
            UnitTools.addLabelInWindow("拒绝邀请加部落申请成功", vc: self)
            self.applyModels.remove(at: (indexPath.row))
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
        
        
    }
    /// 拒绝用户加群申请,群主权限
    func declineUserJoinGroup(at indexPath:IndexPath , _ applyModel  : BKApplyGroupModel) {
        
        EMClient.shared().groupManager.declineJoinGroupRequest(applyModel.groupId, sender: applyModel.customer_uid, reason: "") {[unowned self] (group, error) in
            HUD.hide(animated: true)
            if error != nil {
                UnitTools.addLabelInWindow("拒绝加部落申请失败", vc: self)
            } else {
                
                BKRealmManager.shared().deleteGroupApplay(applyModel.customer_uid)
                UnitTools.addLabelInWindow("拒绝加部落申请成功", vc: self)
                self.applyModels.remove(at: (indexPath.row))
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
            }
            
        }
        
        
    }

 
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
    }
}


// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKGroupApplyViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.applyModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell    = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")
        if cell     == nil {
            cell    = UITableViewCell(style: .default, reuseIdentifier: "TableViewCell")
            cell?.selectionStyle = .none
            // 头像
             let imageView       = UIImageView()
            imageView.tag               = 100
            cell?.contentView.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.top.equalTo((cell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(14.0))
                make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(21.0))
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(40.0), height: CYLayoutConstraintValue(40.0)))
            }
            imageView.setCornerRadius(CYLayoutConstraintValue(20.0))
            
            // 标题
             let titleLabel          = UILabel()

            titleLabel.textColor    = UIColor.colorWithHexString("#333333")
            titleLabel.font         = CYLayoutConstraintFont(15.0)
            titleLabel.tag          = 200;
            
            cell?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints({ (make) in
                make.left.equalTo(imageView.snp.right).offset(CYLayoutConstraintValue(16.5))
                make.top.equalTo((cell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(13.0))
                make.right.equalTo((cell?.contentView.snp.right)!).offset(-CYLayoutConstraintValue(15.0))
            })
            
            
            // 副标题
             let descLabel           = UILabel()
            descLabel.textColor    = UIColor.colorWithHexString("#777777")
            descLabel.font         = CYLayoutConstraintFont(14.0)
            descLabel.tag          = 300;
            cell?.contentView.addSubview(descLabel)
            descLabel.snp.makeConstraints({ (make) in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(CYLayoutConstraintValue(6.0))
            })
            
            // 接受按钮
            let acceptButton                            = UIButton(type: .custom)
            acceptButton.setTitle("接受", for: .normal)
            acceptButton.setTitleColor(UIColor.white, for: .normal)
            acceptButton.backgroundColor                = UIColor.colorWithHexString("#24B497")
            acceptButton.titleLabel?.font               = CYLayoutConstraintFont(14.0)
            acceptButton.titleLabel?.textAlignment      = .center
            acceptButton.tag                            = 400
            acceptButton.setCornerRadius(CYLayoutConstraintValue(3.0))
            acceptButton.addTarget(self, action: #selector(acceptButtonClick(_:event:)), for: .touchUpInside)
            cell?.contentView.addSubview(acceptButton)
            acceptButton.snp.makeConstraints({ (make) in
                make.left.equalTo(titleLabel.snp.left)
                make.top.equalTo(descLabel.snp.bottom).offset(CYLayoutConstraintValue(9.0))
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(72.5), height: CYLayoutConstraintValue(25.0)))
            })
            
            // 拒绝的按钮
            let declineButton                           = UIButton(type: .custom)
            declineButton.tag                           = 500
            declineButton.setTitle("拒绝", for: .normal)
            declineButton.backgroundColor               = UIColor.colorWithHexString("#FAB66F")
            declineButton.setTitleColor(UIColor.white, for: .normal)
            declineButton.titleLabel?.font              = CYLayoutConstraintFont(14.0)
            declineButton.titleLabel?.textAlignment     = .center
            declineButton.setCornerRadius(CYLayoutConstraintValue(3.0))
            declineButton.addTarget(self, action: #selector(declineButtonClick(_:event:)), for: .touchUpInside)

            cell?.contentView.addSubview(declineButton)
            declineButton.snp.makeConstraints({ (make) in
                make.left.equalTo(acceptButton.snp.right).offset(CYLayoutConstraintValue(9.0))
                make.top.equalTo(descLabel.snp.bottom).offset(CYLayoutConstraintValue(9.0))
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(72.5), height: CYLayoutConstraintValue(25.0)))
            })
            
            
        }
        
        let imageView           = cell?.contentView.viewWithTag(100) as! UIImageView
        imageView.image         = KCustomerUserHeadImage
        let titleLabel          = cell?.contentView.viewWithTag(200) as! UILabel
        let descLabel           = cell?.contentView.viewWithTag(300) as! UILabel
        let acceptButton        = cell?.contentView.viewWithTag(400) as! UIButton
        let declineButton       = cell?.contentView.viewWithTag(500) as! UIButton
        
        
        let applyModel          = self.applyModels[indexPath.row]
        
        titleLabel.text         = applyModel.title
        descLabel.text          = String(format: "%@", applyModel.reason)
        let showButton          = applyModel.applyType == .joinGroup || applyModel.applyType == .InviteGroup
        
        if showButton {
            acceptButton.isHidden   = false
        } else {
            acceptButton.isHidden   = true
        }
        
        declineButton.isHidden  = acceptButton.isHidden
        var url : URL?
        if applyModel.applyType == .joinGroup {
            url = URL(string: applyModel.userAvatar)
        } else {
            url = URL(string: applyModel.groupAvatar)
        }
        
        imageView.kf.setImage(with: url, placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)

        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let applyModel          = self.applyModels[indexPath.row]
        switch applyModel.applyType {
        case .joinGroup , .InviteGroup :
            return CYLayoutConstraintValue(98.0)
        default:
            return CYLayoutConstraintValue(73.0)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let rowAction = UITableViewRowAction(style: .destructive, title: "删除") {[unowned self] (rowAction, indexPath) in
            let applyModel          = self.applyModels[indexPath.row]
            BKRealmManager.shared().deleteGroupApplay(applyModel.customer_uid)
            self.applyModels.remove(at: (indexPath.row))
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [rowAction]
        
    }
}

