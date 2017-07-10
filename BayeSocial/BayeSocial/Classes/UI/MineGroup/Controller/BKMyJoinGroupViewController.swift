//
//  BKMyJoinGroupViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/28.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 我的社群
class BKMyJoinGroupViewController: BKBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.creatUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadDatas()
    }
   
    var groupArray : [BKChatGroupModel] = [BKChatGroupModel]()
    lazy var tableView : UITableView = {
        
        let tableView               = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(UINib(nibName: "BKMineJoinGroupViewCell", bundle: nil), forCellReuseIdentifier: "BKMineJoinGroupViewCell")
        tableView.delegate          = self
        tableView.dataSource        = self
        tableView.tableFooterView   = UIView()
        return tableView
    }()
    
    /// 创建UI
    func creatUI() {
    
        self.view.backgroundColor       = UIColor.clear
        self.title                      = "我的部落"
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.view.snp.top).offset(64.0)
            make.left.bottom.right.equalTo(self.view)
        }
    
        self.setRightBarbuttonItemWithTitles(["创建部落"], actions: [#selector(BKMyJoinGroupViewController.createGroup)])
    }
    
    /// 请求群资料信息
    func loadDatas() {
     
        let groups : [EMGroup]  = EMClient.shared().groupManager.getJoinedGroups() as! [EMGroup]
        if groups.count > 0 {
            self.reqeustMineJoinGroups(by: groups)
        }
        
    }
    
    /// 请求群我加入社群的列表
    func reqeustMineJoinGroups(by groupIds : [EMGroup]) {
        
        var publicGroups : [String]                             = [String]()
        BKCacheManager.shared.easeMobGroups                = groupIds
        for group in groupIds {
            publicGroups.append(group.groupId)
            BKGlobalOptions.curret.groupDisturbings[group.groupId]    = group.isPushNotificationEnabled;
        }

        let groupsString : String = UnitTools.arrayTranstoString(publicGroups)
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getOperationReqeust(KURL_MineJoinChat_groupsApi, params: ["groupids" : groupsString], success: {[weak self] (success) in
            HUD.hide(animated: true)

            let json            = success.value
            let chat_groups     = json["chat_groups"]?.arrayValue
            guard chat_groups   != nil else {
                let error_code  = json["error_code"]?.int
                if error_code   != nil  {
                    let msg     = json["error"]?.stringValue ?? "获取我的部落失败"
                    UnitTools.addLabelInWindow(msg, vc: self)
                }
                return
            }

            self?.groupArray     = BKChatGroupModel.chatGroupsWithJSONArray(chat_groups!)
            BKRealmManager.shared().insertChatGroup((self?.groupArray)!)
            
            self?.tableView.reloadData()
            
        }) {[weak self] (failure) in
            
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
        
        }

    }
    
    deinit {
     
        NJLog(self)
     
    }
    
    /// 创建社群
    func createGroup() {
        
        let creatGroupViewController = BKCreateGroupViewController()
        self.navigationController?.pushViewController(creatGroupViewController, animated: true)
        
    }

    
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKMyJoinGroupViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell                            = tableView.dequeueReusableCell(withIdentifier: "BKMineJoinGroupViewCell") as! BKMineJoinGroupViewCell
        let group                           = self.groupArray[indexPath.row]
        cell.groupModel                     = group
        cell.disturbingButton.isHidden      = !BKGlobalOptions.curret.groupDisturbings[group.groupid!]!

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(60.0)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let group                   = self.groupArray[indexPath.row]
        EMIMHelper.shared().hy_chatRoom(withConversationChatter: group.groupid!,soureViewController: self)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset     = UIEdgeInsets.zero
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.separatorInset   = UIEdgeInsets.zero
        
    }
    
}
