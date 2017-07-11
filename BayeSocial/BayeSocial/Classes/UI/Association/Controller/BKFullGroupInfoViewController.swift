//
//  BKFullGroupInfoViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/25.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 完善资料的模型
class BKFullInfoModel: NSObject {
    var title : String?
    var subTitle : String?
    
    convenience init( title : String, subTitle :String) {
        self.init()
        self.title      = title
        self.subTitle   = subTitle
    }
    
}
/// 完善群资料的控制器
class BKFullGroupInfoViewController: BKBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dataArray : [[BKFullInfoModel]] = [[BKFullInfoModel]]()
    var avatar : String?
    var category_uid : String?
    var isPublicGroup : Bool        = true
    var is_approval : Bool          = true
    var desc : String?
    var city : String?
    var province : String?
    var groupname : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.loadDatas()
        
    }
    
    func setup() {
        
        self.leftTitle                              = "完善部落资料"
        self.automaticallyAdjustsScrollViewInsets   = true
        self.tableView.separatorColor               = UIColor.colorWithHexString("#D2D2D2")
        self.tableView.register(UINib(nibName: "BKFullInfoCategoryViewCell", bundle: nil), forCellReuseIdentifier:"BKFullInfoCategoryViewCell")
        self.tableView.register(UINib(nibName: "BKGroupIntroducetViewCell", bundle: nil), forCellReuseIdentifier:"BKGroupIntroducetViewCell")
        
        self.addFooterView()
    }
    
    override func popToBack() {
        self.tableView.endEditing(true)
        self.navigationController?.popViewControllerAnimated(true, delay: 0.25)
    }
    
    /// 尾部视图
    func addFooterView() {
     
        let footerView                          = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(234.0)))
        self.tableView.tableFooterView          = footerView
        // 标题
        let label                               = UILabel()
//        label.text                              = "创建部落即表示您已同意《巴爷汇部落协议》"
        label.textAlignment                     = .center
        label.font                              = CYLayoutConstraintFont(14.0)
        label.textColor                         = UIColor.colorWithHexString("#969696")
        footerView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(footerView.snp.top).offset(CYLayoutConstraintValue(14.0))
            make.left.right.equalTo(footerView)
        }
        // 创建群的按钮
        let createButton                        = UIButton(type: .custom)
        createButton.backgroundColor            = UIColor.colorWithHexString("#39BBA1")
        createButton.setTitle("创建部落", for: .normal)
        createButton.setTitleColor(UIColor.white, for: .normal)
        createButton.titleLabel?.textAlignment  = .center
        createButton.addTarget(self, action: #selector(BKFullGroupInfoViewController.createGroupBtnClick(btn:)), for: .touchUpInside)
        createButton.setCornerRadius(CYLayoutConstraintValue(4.0))
        createButton.titleLabel?.font           = CYLayoutConstraintFont(16.0)
        footerView.addSubview(createButton)
        createButton.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(CYLayoutConstraintValue(43.0))
            make.left.equalTo(footerView.snp.left).offset(CYLayoutConstraintValue(20.0))
            make.right.equalTo(footerView.snp.right).offset(-CYLayoutConstraintValue(20.0))
            make.height.equalTo( CYLayoutConstraintValue(50.0))
        }
        
        
        
    }
    
    /// 城市选择器
    func showUserLocationView() {
        
        let cityPickerView  = BKCityPickerView(frame: self.view.frame)
        cityPickerView.showInView(self.view) {[weak self] (province, city, district) in
            self?.province = province!
            self?.city     = city!
            let fullModel = self?.dataArray[0][1];
            fullModel?.subTitle = self?.city
            self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }

    }
    
    /// 加载数组
    func loadDatas() {
        
        let grupCategory            = BKFullInfoModel(title: "部落分类", subTitle: "")
        
        let location                = BKFullInfoModel(title: "所在地", subTitle: "")
        
        let other                   = BKFullInfoModel(title: "", subTitle: "")
        
        let joinJurisdiction        = BKFullInfoModel(title: "加入部落权限", subTitle: "无需验证")
        
        let activityJurisdiction    = BKFullInfoModel(title: "动态访问权限", subTitle: "所有人可见")
        
    
        self.dataArray = [[grupCategory,location],[other],[joinJurisdiction,activityJurisdiction]];
        
        self.tableView.reloadData()

        
    }
    
    /// 建群的按钮点击事件
    @objc func createGroupBtnClick(btn : UIButton) {
        
        guard self.avatar != nil else {
            UnitTools.addLabelInWindow("请上传部落头像", vc: self)
            return
        }
        
        guard self.category_uid != nil else {
            UnitTools.addLabelInWindow("请选择部落分类", vc: self)
            return
        }
        
        guard self.groupname != nil else {
            UnitTools.addLabelInWindow("请填写部落名称", vc: self)
            return
        }
        guard self.city != nil else {
            UnitTools.addLabelInWindow("请选部落所在地", vc: self)
            return
        }
        guard self.desc != nil else {
            UnitTools.addLabelInWindow("请填写部落描述信息", vc: self)
            return
        }

        var params                          = [String:Any]()
        params["chat_group_category_uid"]   = self.category_uid!
        var chat_group                      = [String : Any]()
        chat_group["groupname"]             = self.groupname!
        chat_group["avatar"]                = self.avatar!
        if self.province != nil {
            chat_group["province"]          = self.province!
        }
        if self.city != nil {
            chat_group["city"]              = self.city!
        }
        
        chat_group["desc"]                  = self.desc!
        chat_group["is_approval"]           = self.is_approval
        chat_group["is_public"]             = true
        chat_group["maxusers"]              = 300
        params["chat_group"]                = chat_group
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.postReqeust(KURL_Chat_groupsCreate, params: params, success: {[weak self] (result) in
            
                HUD.hide(animated: true)
                let json                        = result.value
                let notice                      = json["notice"]?.dictionaryValue
                let code                        = notice?["code"]?.intValue
                let message                     = notice?["message"]?.stringValue
                if code == 403 {
                  UnitTools.addLabelInWindow(message!, vc: self)
                } else  {
                    let chat_group = json["chat_group"]?.dictionaryValue
                    if chat_group != nil {
                        
                        let chatGroup    = BKChatGroupModel(by: JSON(chat_group!))
                        NotificationCenter.bk_postNotication("createGroupSuccess", object: chatGroup)
                        UnitTools.addLabelInWindow("创建部落成功!", vc: self)
                        self?.navigationController?.popToRootViewControllerAnimated(true, delay: 1.0)

                    } else {
                        UnitTools.addLabelInWindow("创建部落失败!", vc: self)
                    }
                }
            
            }) {[weak self] (result) in
                HUD.hide(animated: true)

                UnitTools.addLabelInWindow(result.errorMsg, vc: self)
                
        }
        
    }
    
    /// 存储新建的群
    func insertChatUserToDataBase(_ chatGroup : BKChatGroupModel) {

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tableView.endEditing(true)
        
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.separatorInset = UIEdgeInsets.zero
    }
    
    func showAlertViewWith(titiles :[String],title : String,indexPath : IndexPath) {
        
        
        let _ = YepAlertKit.showAlertView(in: self, title: title, message: nil, titles: titiles, cancelTitle: nil, destructive: nil) {[weak self] (index) in
            if index == 3 {
                return
            }
            let fullModel = self?.dataArray[indexPath.section][indexPath.row];
            if indexPath.row == 0 {
                fullModel?.subTitle = index == 1 ? "需要验证加入" : "无需验证"
                self?.is_approval = index == 1 ? true : false
            } else if indexPath.row == 1 {
                fullModel?.subTitle = index == 1 ? "所有人可见" : "仅部落管理员可见"
            }
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension BKFullGroupInfoViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = self.dataArray[section]
        return arr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section  != 1 {
            
            let cell                = tableView.dequeueReusableCell(withIdentifier:"BKFullInfoCategoryViewCell") as! BKFullInfoCategoryViewCell
            let fullGroupModel      = self.dataArray[indexPath.section][indexPath.row]
            cell.titleLabel.text    = fullGroupModel.title
            
            cell.detailLabel.text   = fullGroupModel.subTitle
            
            return cell
            
        } else  {
            
            let cell            = tableView.dequeueReusableCell(withIdentifier:"BKGroupIntroducetViewCell") as! BKGroupIntroducetViewCell
            cell.delegate       = self
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.00001 : 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section != 1 ? CYLayoutConstraintValue(44.0) : CYLayoutConstraintValue(168.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        // 群分类
        if indexPath.section == 0 && indexPath.row == 0 {
            let groupCategory           = BKGroupCategoryViewController()
            groupCategory.delegate      = self
            self.navigationController?.pushViewController(groupCategory, animated: true)
        }
        // 所在地
        if indexPath.section == 0 && indexPath.row == 1  {
            self.showUserLocationView()
        }
        // 加入社群权限
        if indexPath.section == 2 && indexPath.row == 0  {
            self.showAlertViewWith(titiles: ["需要验证加入","无需验证","取消"], title: "加入部落权限", indexPath: indexPath)
        }
        // 动态访问权限
        if indexPath.section == 2 && indexPath.row == 1  {
            self.showAlertViewWith(titiles: ["所有人可见","仅部落管理员可见","取消"], title: "动态访问权限", indexPath: indexPath)

        }
        
    }
}

// MARK: - BKGroupCategoryViewControllerDelegate
extension BKFullGroupInfoViewController : BKGroupCategoryViewControllerDelegate {
    
    /// 选择了某个群分类
    
    func didSelectGroupCategorys(_ viewController: BKGroupCategoryViewController, category: BKGroupCategory) {
        
        let uid                     = category.uid
        let name                    = category.name
        self.category_uid           = uid!
        let fullModel               = self.dataArray[0].first
        fullModel?.subTitle         = name
        
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
    }
}


// MARK: - BKGroupIntroducetViewCellDelegate

extension BKFullGroupInfoViewController : BKGroupIntroducetViewCellDelegate {
    
    func didInputGroupDescription(_ cell: BKGroupIntroducetViewCell, desc: String) {
        self.desc = desc
    }
    
    
}
