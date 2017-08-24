//
//  BKPrivacySettingViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/24.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 隐私设置
class BKPrivacySettingViewController: BKBaseTableViewController {

    var dataArray : [[[String : String]]]   = [[[String : String]]]()
    var mobilePrivacyDisplayOptions : [String : String]          = ["所有人可见手机号" : "所有人","仅好友可见手机号" : "仅好友","手机号保密" : "保密"]
    var namecardPrivacyDisplayOptions : [String : String]        = ["所有人可见我的资料" : "所有人","仅好友可见我的资料" : "仅好友","我的资料保密" : "保密"]
    var mobilePrivacyType : Int             = 0
    var namecardPrivacyType : Int           = 0
    var mobilePrivacyOptions : [String]     = ["所有人可见手机号","仅好友可见手机号","手机号保密"]
    var namecardPrivacyOptions : [String]   = ["所有人可见我的资料","仅好友可见我的资料","我的资料保密"]
    var selectIndexPath : IndexPath?
    var selectIndex : Int                   = 0
    var noDisturbingStartH : Int        = 22
    var noDisturbingEndH : Int          = 8
    var titleArray : [String]           = ["开启","只在夜间开启（22:00-8:00）","关闭"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadDatas()
        self.getUserPrivacyOptios()
        
    }
    
    func setup() {
        self.title                      = "隐私设置"
    }
    
    /// 获取用户隐私权限设置信息
    func getUserPrivacyOptios() {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getOperationReqeust(baseURLPath + "customers/privacy", params: nil, success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json            = success.value
            let privacy         = json["privacy"]?.dictionary
            guard privacy       != nil else {
                UnitTools.addLabelInWindow("获取隐私设置失败", vc: self)
                return
            }
            
            // 刷新 UI 显示
            let mobile_visible_scope                                    = privacy?["mobile_visible_scope"]?.string ?? "所有人可见手机号"
            let namecard_visible_scope                                  = privacy?["namecard_visible_scope"]?.string ?? "所有人可见我的资料"
            self?.updatePrivacySubTitle(IndexPath(row: 0, section: 0), mobile_visible_scope: mobile_visible_scope, namecard_visible_scope: namecard_visible_scope)
            self?.updatePrivacySubTitle(IndexPath(row: 1, section: 0), mobile_visible_scope: mobile_visible_scope, namecard_visible_scope: namecard_visible_scope)
        
            }) { (failure) in
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
                
        }
        
    }
    
    func loadDatas() {
        
        let sectionOne                  = [
            [
                "title" : "手机号可见",
                "subTitle" : "所有人",
                "desc" :  ""
            ],
            [
                "title"     : "谁可以看我的资料",
                "subTitle"  : "所有人",
                "desc"      :  "包括我的群组，我的人脉、公司地址"
            ]
        ]

        let sectionThree                    = [
            ["title" : "勿扰模式" ,
             "subTitle" : titleArray[BKGlobalOptions.curret.privacyOptions.noDisturbStatus]
            ]
        ]
        
        let sectionTwo                  = [
            [
                "title" : "黑名单",
                "subTitle" : "",
                "desc" :  ""
            ]
        ]
        
        self.dataArray.append(sectionOne)
        self.dataArray.append(sectionThree)
        self.dataArray.append(sectionTwo)
        
        
    }
    
    //MARK: UITableViewDatasource ,UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var cell                            = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell                            = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.selectionStyle            = .none
            
            // 标题
            let titleLabel                  = UILabel()
            titleLabel.font                 = CYLayoutConstraintFont(16.0)
            titleLabel.tag                  = 100
            cell?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints({ (make) in
                make.top.equalTo((cell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(14.0))
                make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(15.0))
            })
            
            // 右边跳转按钮
            let rightArrow                  = UIImageView()
            rightArrow.tag                  = 200
            rightArrow.image                = UIImage(named: "right_nextarrow")
            cell?.contentView.addSubview(rightArrow)
            rightArrow.snp.makeConstraints({ (make) in
                make.right.equalTo((cell?.contentView.snp.right)!).offset(-CYLayoutConstraintValue(20.0))
                make.top.equalTo(titleLabel)
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(8.0), height: CYLayoutConstraintValue(13.0)))
            })
            // 子标题
            let detailLabel                     = UILabel()
            detailLabel.font                    = CYLayoutConstraintFont(14.0)
            detailLabel.textColor               = UIColor.colorWithHexString("#898989")
            detailLabel.tag                     = 300
            detailLabel.textAlignment           = .right
            cell?.contentView.addSubview(detailLabel)
            detailLabel.snp.makeConstraints({ (make) in
                make.centerY.equalTo(rightArrow)
                make.right.equalTo(rightArrow.snp.left).offset(-CYLayoutConstraintValue(11.0))
            })
            
            // 描述内容的 label
            let descLabel                       = UILabel()
            descLabel.font                    = CYLayoutConstraintFont(13.0)
            descLabel.textColor               = UIColor.colorWithHexString("#898989")
            descLabel.tag                     = 500
            descLabel.textAlignment           = .right
            cell?.contentView.addSubview(descLabel)
            descLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(CYLayoutConstraintValue(5.5))
                make.left.equalTo(titleLabel)
            })
            
            
        }
        
        let dict                            = self.dataArray[indexPath.section][indexPath.row]
        let titleLabel                      = cell?.contentView.viewWithTag(100) as! UILabel
        titleLabel.text                     = dict["title"]
    
        let detailLabel                     = cell?.contentView.viewWithTag(300) as! UILabel
        detailLabel.text                    = dict["subTitle"]
        
        let descLabel                       = cell?.contentView.viewWithTag(500) as! UILabel
        descLabel.text                      = dict["desc"]
        
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 0 && indexPath.row == 1) ? CYLayoutConstraintValue(70) : CYLayoutConstraintValue(48.0)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section,indexPath.row) {
        case (1,0) :
            // 勿扰模式
            let _ = YepAlertKit.showAlertView(in: self, title: "勿扰模式", message: nil, titles: titleArray, cancelTitle: nil, destructive: nil, callBack: {[weak self] (index) in
                
                if index == 1 {
                    self?.noDisturbingStartH            = 0
                    self?.noDisturbingEndH              = 24
                } else if index == 2 {
                    self?.noDisturbingStartH            = 22
                    self?.noDisturbingEndH              = 8
                } else {
                    self?.noDisturbingStartH            = -1
                    self?.noDisturbingEndH              = -1
                }
                
                let subTitle                            = self?.titleArray[index-1]
                // 推送时间段类型
                self?.updatePushOptions(at: index-1, subTitle: subTitle!)
            
            })
            
            break
        case (2,0):
            let blackListViewController = BKBlackListViewController()
            self.navigationController?.pushViewController(blackListViewController, animated: true)
            break
        default:
            self.showAlertView(indexPath)
            break
        }
        
    }
    
    /// 更新消息推送的时间段 分为全天推送 不推送 和 勿扰模式推送
    func updatePushOptions(at index : Int , subTitle : String) {
        
        // 设置免打扰类型 和免打扰时间段
        let pushOptions                 = EMClient.shared().pushOptions
        pushOptions?.noDisturbStatus    = EMPushNoDisturbStatus(UInt32(index))
        pushOptions?.noDisturbingStartH = self.noDisturbingStartH
        pushOptions?.noDisturbingEndH   = self.noDisturbingEndH
        pushOptions?.displayName        = BK_UserInfo.name
        
        // 更新推送设置
        weak var weakSelf = self
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        
        EMClient.shared().updatePushNotificationOptionsToServer { (error) in
            HUD.hide(animated: true)
            guard error == nil else {
                UnitTools.addLabelInWindow("设置勿扰模式失败", vc: weakSelf)
                return
            }
            
            // 更新 UI
            var dict                                            = weakSelf?.dataArray[1][0]
            dict?["subTitle"]                                   = subTitle
            weakSelf?.dataArray[1]                              = [dict!]
            weakSelf?.tableView.reloadRows(at:[IndexPath(row: 0, section: 1)], with: .automatic)
            UnitTools.addLabelInWindow("设置勿扰模式成功", vc: weakSelf)
            
            BKRealmManager.beginWriteTransaction()
            BKGlobalOptions.curret.privacyOptions.noDisturbStatus                    = index
            BKRealmManager.commitWriteTransaction()
        }
        
        
    }

}

// MARK: - 隐私设置选项
extension BKPrivacySettingViewController {
    
    /// 更新隐私选项内容
    func updatePrivacySubTitle(_ indexPath : IndexPath,mobile_visible_scope : String,namecard_visible_scope : String) {
    
        var dict                                            = self.dataArray[indexPath.section][indexPath.row]
        var subTitle                                        = ""
        if indexPath.row == 0 {
            subTitle                                        = (self.mobilePrivacyDisplayOptions[mobile_visible_scope])!
        } else {
            subTitle                                        = (self.namecardPrivacyDisplayOptions[namecard_visible_scope])!
        }
        
        dict["subTitle"]                                    = subTitle
        self.dataArray[indexPath.section][indexPath.row]    = dict
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        
        BKRealmManager.beginWriteTransaction()
        
        BKGlobalOptions.curret.privacyOptions.mobile_visible_scope               = mobile_visible_scope
        
        BKGlobalOptions.curret.privacyOptions.namecard_visible_scope             = namecard_visible_scope
        
        BKRealmManager.commitWriteTransaction()
        
    }
    /// 更新用户隐私设置
    func updatePrivacyToServer() {
        
        let mobile_visible_scope                                    = self.mobilePrivacyOptions[self.mobilePrivacyType]
        let namecard_visible_scope                                  = self.namecardPrivacyOptions[self.namecardPrivacyType]
        var params                                                  = [String : String]()
        params["mobile_visible_scope"]                              = mobile_visible_scope
        params["namecard_visible_scope"]                            = namecard_visible_scope
        
        // 修改用户的隐私设置
        BKNetworkManager.patchOperationReqeust(baseURLPath + "customers/privacy", params: params, success: {[weak self] (success) in
            let json                                                = success.value
            let return_code : Int                                   = json["return_code"]?.intValue ?? 0
            let return_message : String                             = json["return_message"]?.string ?? "修改失败"
            if return_code != 200 {
                UnitTools.addLabelInWindow(return_message, vc: self)
            } else {
                self?.updatePrivacySubTitle((self?.selectIndexPath)!, mobile_visible_scope: mobile_visible_scope, namecard_visible_scope: namecard_visible_scope)
                UnitTools.addLabelInWindow(return_message, vc: self)
            }
            
        }) {[weak self] (failure) in
            UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
        }
        
    }
    
    /// 更新 subTitle
    func updateSubTitle(at indexPath : IndexPath,index : Int) {
        
        if indexPath.row == 0 {
            self.mobilePrivacyType              = index
        } else if indexPath.row == 1 {
            self.namecardPrivacyType            = index
        }
        
        self.updatePrivacyToServer()
        self.selectIndexPath                    = indexPath
        self.selectIndex                        = index
        
    }
    
    /// 选项视图
    func showAlertView(_ indexPath : IndexPath) {
                
        let _ = YepAlertKit.showAlertView(in: self, title: nil, message: nil, titles:  ["所有人","仅好友","保密"], cancelTitle: "取消", destructive:  nil) {[weak self] (idx) in
            if idx != 0 {
                self?.updateSubTitle(at: indexPath, index: idx-1)
            }
        }
        
    }

    
    
}

