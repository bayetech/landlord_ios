//
//  BKEditingGroupInfoViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/3.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import PKHUD
import CYPhotosKit

/// 编辑群资料控制器
class BKEditingGroupInfoViewController: BKBaseViewController {
    lazy var tableView : UITableView = {
        let tableView                   = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor       = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        tableView.delegate              = self
        tableView.dataSource            = self
        return tableView
    }()
    var imageArray : [String] = [String]()
    var dataArray : [[[String : String]]]?
    var addImageButtton : UIButton?
    var province : String?
    var city     : String?
    var chat_groupModel : BKChatGroupModel? {
        didSet {
            self.province   = chat_groupModel?.province
            self.city       = chat_groupModel?.city
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title          = "编辑部落资料"
        self.setup()
        self.addHeadView()
        self.loadDatats()
        
        
    }

    func setup() {
    
        self.automaticallyAdjustsScrollViewInsets = true
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    
    }

    /// 头部视图
    
    func addHeadView() {
        
        let headView = UIView()
        headView.backgroundColor = UIColor.white
        self.tableView.tableHeaderView = headView
        headView.snp.makeConstraints { (make) in
            make.top.left.equalTo(self.tableView)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(185.0)))
        }
        
        // 头像
        let headImageButton                     = UIButton(type : .custom)
        headImageButton.layer.cornerRadius      = CYLayoutConstraintValue(60.0)
        headImageButton.layer.masksToBounds     = true
        headView.addSubview(headImageButton)
        headImageButton.addTarget(self, action: #selector(BKEditingGroupInfoViewController.uploadImage), for: .touchUpInside)
        headImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(headView.snp.top).offset(CYLayoutConstraintValue(17.0))
            make.centerX.equalTo(headView)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(120.0), height: CYLayoutConstraintValue(120.0)))
        }
        
        self.addImageButtton        = headImageButton
        // 设置网络头像
        let avatar                  = self.chat_groupModel?.avatar ?? ""
        self.addImageButtton?.kf.setBackgroundImage(with: URL(string :avatar), for: .normal, placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        
        // label
        let label                   = UILabel()
        label.textAlignment         = .center
        label.text                  = "更换头像"
        headView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(headImageButton.snp.bottom)
            make.left.right.bottom.equalTo(headView)
        }
        
        self.tableView.tableFooterView = UIView()
        
        
    }
    
    
    /// 更新群资料
    func updateChatGroupData() {
        
        guard self.chat_groupModel != nil else {
            return
        }
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)

        var params                          = [String:Any]()
        params["chat_group_category_uid"]   = self.chat_groupModel?.category_id ?? ""
        var chat_group                      = [String : Any]()
        chat_group["groupname"]             = sectionSubTitle(at: (section: 0, row: 0))
        chat_group["avatar"]                = self.imageArray.last ?? ""
        chat_group["desc"]                  = sectionSubTitle(at: (section: 2, row: 0))
        let is_approval                     = sectionSubTitle(at: (section: 3, row: 0)) // 是否验证
        NJLog(is_approval)
        chat_group["is_approval"]           = (is_approval == "无需验证") ? false : true
        chat_group["is_public"]             = true
        chat_group["maxusers"]              = 300
        if let province                     = self.province {
            chat_group["province"]          = province
        }
        if let city                         = self.city {
            chat_group["city"]              = city
        }
        params["chat_group"]                = chat_group

        let groupId                         = self.chat_groupModel?.groupid ?? ""
        let requestURL                      = KURL_MineJoinChat_groupsApi + "/\(groupId)"
        
        BKNetworkManager.patchOperationReqeust(requestURL, params: params, success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json            = success.value
            let chat_group  = json["chat_group"]?.dictionaryValue
            let err_code    = json["err_code"]?.int
            guard chat_group != nil else {
                if err_code != nil {
                    let error = json["error"]?.stringValue
                    UnitTools.addLabelInWindow(error!, vc: self)
                }
                return
            }
            
            let chatGroup               = BKChatGroupModel(by: JSON(chat_group!))
            
            BKRealmManager.shared().insertChatGroup([chatGroup])
            
            UnitTools.addLabelInWindow("更新资料成功", vc: self)
            
            }) {[weak self] (failure) in
                
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
                
        }
        
    }
    
    func loadDatats() {
    
        let groupName           = self.chat_groupModel?.groupname ?? ""
        let categroy            = self.chat_groupModel?.category ?? ""
        let city                = self.chat_groupModel?.city ?? "未知"
        let desc                = self.chat_groupModel?.desc ?? ""
        var is_approval         = false
        if self.chat_groupModel != nil {
             is_approval        = (self.chat_groupModel?.is_approval)!
        }
        
        let dictOne             = ["title" : "部落名称","subTitle" : groupName]
        let dictTwo             = ["title" : "部落分类","subTitle" : categroy]
        let dictThree           = ["title" : "所在地","subTitle" : city]

        let dictFour            = ["title" : "部落介绍","subTitle" : desc]
        let dictFive            = ["title" : "加入部落权限","subTitle" : !is_approval ? "无需验证" : "需要验证加入"]
//        let dictSix             = ["title" : "动态访问权限","subTitle" : is_approval ? "仅部落主可见" : "所有人可见"]

        self.dataArray          = [[dictOne],[dictTwo,dictThree],[dictFour],[dictFive]]
        self.tableView.delayReload(with: 0.1)
        
    }
    
    /// 城市选择器
    func showUserLocationView() {
        

        
        let cityPickerView  = BKCityPickerView(frame: self.view.frame)
        cityPickerView.showInView(self.view) {[weak self] (province, city, district) in
            self?.province = province!
            self?.city     = city!
            self?.reloadSubTitle(subTitle: (self?.city)!, indexPath: IndexPath(item: 1, section: 1))
        }

        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.separatorInset = UIEdgeInsets.zero
        
    }
    
    func showAlertTextField(_ title : String,indexPath : IndexPath) {
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    
        var textField : UITextField?
        alertController.addTextField { (tf) in
            textField = tf
        }
        
        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: {[unowned self] (alertAction) in
            let text                                            = textField?.text ?? ""
            self.reloadSubTitle(subTitle: text, indexPath: indexPath)
        }))
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (alertAction) in
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    /// 刷新某个 section 的某个 cell 的 UI

    func reloadSubTitle(subTitle : String,indexPath : IndexPath) {
        
        var dict                                            = self.sectionData(at: indexPath)
        dict["subTitle"]                                    = subTitle
        self.dataArray?[indexPath.section][indexPath.row]   = dict
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        self.updateChatGroupData()
        
    }
    
    /// 获取某个 section 上的数据源 
    
    func sectionData(at indexPath : IndexPath) -> [String : String] {
        let array                                           = self.dataArray![indexPath.section]
        let  dict                                           = array[indexPath.row]
        return dict
    }
    
    /// 获取某个 section 的 subTitle
    func sectionSubTitle(at tuple: (section : Int ,row : Int)) -> String {
        
        let indexPath                                       = IndexPath(row: tuple.row, section: tuple.section)
        let dict                                            = self.sectionData(at: indexPath)
        let subTitle                                        = dict["subTitle"]
        return subTitle!
        
    }
    
    func showAlertPicker(_ tilte : String, items: [String],indexPath : IndexPath) {
        
        let _ = YepAlertKit.showAlertView(in: self, title: title, message: nil, titles: items, cancelTitle: "取消", destructive: nil) {[weak self] (index) in
            guard index != 0 else {
                return
            }
            let subTitle = items[index - 1]
            self?.reloadSubTitle(subTitle: subTitle, indexPath: indexPath)
        }
        
    }
    
    
    /// 上传头像
    func uploadImage() {
        
      
        let _ = YepAlertKit.showActionSheet(in: self, title: nil, message: nil, titles: ["从相册选择","拍照"], cancelTitle: "取消", destructive: nil) {[weak self] (index) in
            if index == 1 {
                self?.pickimageFrowLibrary()
            } else if index == 2 {
                self?.takePhotos()
            }
            
        }
        
    }
    
    /// 从相册选择图片
    func pickimageFrowLibrary() {
        
        let photosNav                   = CYPhotoNavigationController.showPhotosView()
        photosNav.maxPickerImageCount   = 1
        photosNav.delegate              = self
        self.present(photosNav, animated: true, completion: nil)
        
    }
    
    /// 拍照功能
    func takePhotos() {
        
        if  !UIImagePickerController.isSourceTypeAvailable(.camera) {
            UnitTools.addLabelInWindow("相机功能不可用!", vc: self)
            return
        }
        let photoNav            = UIImagePickerController()
        photoNav.delegate       = self
        photoNav.allowsEditing  = true
        photoNav.sourceType     = .camera
        self.present(photoNav, animated: true, completion: nil)
        
    }
    
    
    /// 上传头像
    func uploadGroupAvatar(_ image : UIImage) {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        
        let width               = KScreenWidth
        let height              = KScreenHeight
        let minx                = min(width, height)
        let smallImage          = image.withImage(image, scaledTo: CGSize(width:minx,height:minx))

        
        BKAliCloudUploadManager.manager.asyncUploadImage(smallImage ,completion: {[weak self] (imageFileNames,finished) in
            HUD.hide(animated: true)
            
            self?.imageArray.removeAll()
            self?.imageArray = imageFileNames;
            if (self?.imageArray.count)! > 0 {
                self?.addImageButtton?.setImage(smallImage, for: .normal)
                self?.updateChatGroupData()
            } else {
                UnitTools.addLabelInWindow("上传部落头像失败,请重试", vc: self)
            }
            
        })
    }

}
// MARK: - CYPhotoNavigationControllerDelegate
extension BKEditingGroupInfoViewController : CYPhotoNavigationControllerDelegate {
    
    func cyPhotoNavigationController(_ controller: CYPhotoNavigationController?, didFinishedSelectPhotos result: [CYPhotosAsset]?) {
        
        let photosAsset = (result?.last)! as CYPhotosAsset
        let image       = photosAsset.originalImg
        self.uploadGroupAvatar(image!)
        
    }
    
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKEditingGroupInfoViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard self.dataArray?.count != nil else {
            return 0
        }
        return (self.dataArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let     arr = self.dataArray![section]
        return arr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        
        if cell == nil  {
            
            cell = UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
            cell?.textLabel?.textColor = UIColor.colorWithHexString("#969696")
            cell?.textLabel?.font      = CYLayoutConstraintFont(16.0)
            cell?.selectionStyle       = .none
            cell?.accessoryType        = .disclosureIndicator
        }
        
        let arr                         = self.dataArray![indexPath.section]
        let dict                        = arr[indexPath.row]
        cell?.textLabel?.text           = dict["title"]
        cell?.detailTextLabel?.text     = dict["subTitle"]
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(44.0)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 || indexPath.section == 2 {
            let title   = indexPath.section == 0 ? "部落名称" : "部落介绍"
            self.showAlertTextField(title, indexPath: indexPath)
        } else {
            
            if indexPath.section == 1  {
                
                if indexPath.row == 0 {
                    let groupCategoryViewController             = BKGroupCategoryViewController()
                    groupCategoryViewController.delegate        = self
                    self.navigationController?.pushViewController(groupCategoryViewController, animated: true)
                } else {
                    self.showUserLocationView() // 城市选择器
                }
                
            } else if indexPath.section == 3 {
                
                let items : [String]    = indexPath.row == 0 ? ["需要验证加入","无需验证"] : ["所有人可见","仅部落管理员可见"]
                let title : String      = indexPath.row == 0 ? "加入部落权限" : "动态访问权限"
                self.showAlertPicker(title, items: items, indexPath: indexPath)
                
            }
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(10.0)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.separatorInset = UIEdgeInsets.zero
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

// MARK: - BKGroupCategoryViewControllerDelegate

extension BKEditingGroupInfoViewController : BKGroupCategoryViewControllerDelegate {
    
    func didSelectGroupCategorys(_ viewController: BKGroupCategoryViewController, category: BKGroupCategory) {

        self.chat_groupModel?.category_id   = category.uid
        let name                            = category.name
        self.reloadSubTitle(subTitle: name!, indexPath: IndexPath(row: 0, section: 1))
        
    }

    
}

// MARK: - UIImagePickerControllerDelegate , UINavigationControllerDelegate
extension BKEditingGroupInfoViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    //点击UIImagePickerController 取消按钮时隐藏个人中心nav
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let type :NSString        = info["UIImagePickerControllerMediaType"] as! NSString
        if(type.isEqual(to: "public.image")) {
            picker.dismiss(animated: true, completion:nil)
            let image :UIImage  = info["UIImagePickerControllerEditedImage"] as! UIImage
            self.uploadGroupAvatar(image)
            //            self.addImageButtton.setImage(image, for: .normal);
        }
        
    }
    
    
}
