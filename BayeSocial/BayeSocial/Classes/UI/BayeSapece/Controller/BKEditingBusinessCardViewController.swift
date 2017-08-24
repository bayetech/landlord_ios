//
//  BKEditingBusinessCardViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/4.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD
import CYPhotosKit

class BusinessCardModel: NSObject {
    
    var title : String          = ""
    var subTitle : String       = ""
    convenience init(title : String,subTitle : String) {
        self.init()
        self.title              = title
        self.subTitle           = subTitle
    }
    
}

/// 编辑名片的控制器

class BKEditingBusinessCardViewController: BKBaseViewController {
    
    var addImageButtton : UIButton?
    lazy var tableView : UITableView    = {
        let tableView                   = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor       = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        tableView.delegate              = self
        tableView.dataSource            = self
        tableView.tableFooterView       = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 30.0))
        return tableView
    }()
    var dictArray : [[BusinessCardModel]] = [[BusinessCardModel]]()
    var imageArray : [String] = [String]()
    var province : String = ""
    var city : String = ""
    var userInfo : UserInfo?
    var industyItems : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.addHeadView()
        
    }
    
    func setup() {
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!)
        }
        
        self.automaticallyAdjustsScrollViewInsets   = true
        self.userInfo                               = BK_UserInfo
        self.loadDatas()
                
    }
 
    override func popToBack() {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    /// 头部视图
    
    func addHeadView() {
        
        let headView                            = UIView()
        headView.backgroundColor                = UIColor.white
        self.tableView.tableHeaderView          = headView
        headView.snp.makeConstraints { (make) in
            make.top.left.equalTo(self.tableView)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(185.0)))
        }
        
        // 头像
        let headImageButton                     = UIButton(type : .custom)
        headImageButton.layer.cornerRadius      = CYLayoutConstraintValue(60.0)
        headImageButton.layer.masksToBounds     = true
        headImageButton.setBackgroundImage(KCustomerUserHeadImage, for: .normal)
        headView.addSubview(headImageButton)
        headImageButton.addTarget(self, action: #selector(BKEditingGroupInfoViewController.uploadImage), for: .touchUpInside)
        headImageButton.snp.makeConstraints { (make) in
            make.top.equalTo(headView.snp.top).offset(CYLayoutConstraintValue(17.0))
            make.centerX.equalTo(headView)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(120.0), height: CYLayoutConstraintValue(120.0)))
        }
        self.addImageButtton                    = headImageButton
        
        // label
        let label                               = UILabel()
        label.textAlignment                     = .center
        label.text                              = "更换头像"
        headView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(headImageButton.snp.bottom)
            make.left.right.bottom.equalTo(headView)
        }
        
        self.tableView.tableFooterView          = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 30.0))
        self.addImageButtton?.kf.setBackgroundImage(with: URL(string : (self.userInfo?.avatar ?? "")), for: .normal, placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        
    }
    
    
    
    /// 加载数据
    func loadDatas() {
        
        let name                    = self.userInfo?.name
        let sex                     = (self.userInfo?.gender ?? "男")
        let mobile                  = self.userInfo?.mobile ?? "保密"
        let jobTitle                = self.userInfo?.company_position
        let company                 = self.userInfo?.company ?? ""
        let address                 = self.userInfo?.detail_address
        let city                    = self.userInfo?.city
        let industyString           = self.userInfo?.industry_function_items
       
        let businessNameM           = BusinessCardModel(title: "姓名", subTitle: name!)
        let businessSexM            = BusinessCardModel(title: "性别", subTitle: sex)
        let businessMobilM          = BusinessCardModel(title: "机号", subTitle: mobile)
        let businessTitleM          = BusinessCardModel(title: "职位", subTitle: jobTitle!)
        let businessCompanyM        = BusinessCardModel(title: "公司", subTitle: company)
        let businessAddressM        = BusinessCardModel(title: "详细地址", subTitle: address!)
        let businessCityM           = BusinessCardModel(title: "城市", subTitle: city!)
        let businessIndustryM       = BusinessCardModel(title: "行业职能", subTitle: industyString!)
        
        let arrayOne : [BusinessCardModel]  = [
            businessNameM,
            businessSexM,
            businessMobilM
        ]
        
        let arrayTwo : [BusinessCardModel]  = [
            businessTitleM,
            businessCompanyM,
            businessAddressM
        ]
        
        let arrayThree : [BusinessCardModel] = [
            businessCityM,
            businessIndustryM
        ]
        
        self.dictArray.append(arrayOne)
        self.dictArray.append(arrayTwo)
        self.dictArray.append(arrayThree)
        self.tableView.delayReload(with: 0.1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.separatorInset = UIEdgeInsets.zero
    }
    
    
    /// 选择性别
    func showSexPicker() {
        
        
        let _ = YepAlertKit.showAlertView(in: self, title: "修改性别", message: nil, titles: ["男","女"], cancelTitle: "取消", destructive: nil) {[weak self] (index) in
            guard index != 0 else {
                return
            }
            let title = index == 1 ? "男" : "女"
            self?.reloadSubTitle(title, indexPath: IndexPath(row: 1, section: 0))
        }
        
   
    }
    
    /// 获取某个 section 的 subTitle
    func sectionSubTitle(at tuple: (section : Int ,row : Int)) -> String {
        
        let indexPath                                        = IndexPath(row: tuple.row, section: tuple.section)
        let model                                            = self.sectionData(at: indexPath)
        let subTitle                                         = model.subTitle
        
        return subTitle
    }
    
    /// 刷新子tittle 根据indexPath
    func reloadSubTitle(_ text : String , indexPath : IndexPath) {
        
        let model                                               = self.dictArray[indexPath.section][indexPath.row]
        model.subTitle                                          = text
        self.dictArray[indexPath.section][indexPath.row]        = model
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        self.updateUserInfo()
        
    }
    
    /// 获取某个 section 上的数据源
    
    func sectionData(at indexPath : IndexPath) -> BusinessCardModel {
        
        let array                                    = self.dictArray[indexPath.section]
        
        let  model                                   = array[indexPath.row]
        
        return model
    
    }
    
    /// 行业职能
    func showInsdustryFuncationView() {
    
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getOperationReqeust(KURL_Industry_functions, params: nil, success: {[weak self] (success) in
            
            HUD.hide(animated: true)
            let json                 = success.value
            let industry_functions   = json["industry_functions"]?.arrayValue
            
            let industryArray        = BKIndustryMainModel.industryWithArray(industry_functions!)
            
            // 将行业智能数据保存到数据中去
            BKRealmManager.shared().insertIndustryModel(industryArray)
            
            // 创建行业分类的视图
            let insdutryView                = BKIndustryfunctionView()
            insdutryView.delegate           = self
            self?.view.addSubview(insdutryView)
            insdutryView.snp.makeConstraints { (make) in
                make.edges.equalTo((self?.view)!)
            }
            
        }) { (failure) in
            
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow(failure.errorMsg, vc: nil)
        }
        
    }
    
    /// 城市选择器
    func showUserLocationView() {
        
        let cityPickerView  = BKCityPickerView(frame: self.view.frame)
        cityPickerView.showInView(self.view) {[weak self] (province, city, district) in
            self?.province  = province!
            self?.city      = city!
            self?.reloadSubTitle((self?.city)!, indexPath: IndexPath(item: 0, section: 2))
        }

        
    }
    

    /// 更新用户资料
    func updateUserInfo() {
        
        let name                                = sectionSubTitle(at: (section: 0, row: 0))
        let sex                                 = sectionSubTitle(at: (section: 0, row: 1))
        let jobTitle                            = sectionSubTitle(at: (section: 1, row: 0))
        let company                             = sectionSubTitle(at: (section:1, row: 1))
        let avatar                              = self.imageArray.last ?? ""
        let address                             = sectionSubTitle(at: (section: 1, row: 2))
        let city                                = self.city
        let province                            = self.province

        var params :[String : String]           = [String : String]()
        params["name"]                          = name
        params["gender"]                        = sex
        params["company_position"]              = jobTitle
        params["company"]                       = company
        params["detail_address"]                = address
        params["city"]                          = city
        params["province"]                      = province
        params["avatar"]                        = avatar
        
        if self.industyItems != nil {
            params["industry_function_item_uids"]   = self.industyItems!
        }
        
        // 空值去除
        for (_,string) in params.keys.enumerated() {
            if let value = params[string] {
                if value == "" {
                    params.removeValue(forKey: string)
                }
            }
        }
     
        BKNetworkManager.patchOperationReqeust(KURL_CustomersProfile, params: params, success: {[weak self] (success) in
                HUD.hide(animated: true)
                let json            = success.value
                let return_code     = json["return_code"]?.intValue
                let message         = json["return_message"]?.string ?? "修改失败"
                guard return_code == 200 else {
                    UnitTools.addLabelInWindow(message, vc: self)
                    return
                }
                UnitTools.addLabelInWindow(message, vc: self)
                self?.imageArray.removeAll()
            }) { (failure) in
                HUD.hide(animated: true)
        }
        
    }
    
    deinit {
        
        NJLog(self)
        
    }
    
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKEditingBusinessCardViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.dictArray.count != 0 else {
            return 0
        }
        return self.dictArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = self.dictArray[section]
        return array.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            
            cell                                = UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
            cell?.selectionStyle                = .none
            
            cell?.textLabel?.font               = CYLayoutConstraintFont(16.0)
            cell?.textLabel?.textColor          = UIColor.colorWithHexString("#969696")
            
            cell?.detailTextLabel?.font         = CYLayoutConstraintFont(16.0)
            
        }
        
        let model                                = self.dictArray[indexPath.section][indexPath.row]

        cell?.textLabel?.text                   = model.title
        cell?.detailTextLabel?.text             = model.subTitle
        
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(44.0)
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model                                   = self.dictArray[indexPath.section][indexPath.row]
        let title                                   = model.title
        let content                                 = model.subTitle
        switch (indexPath.section,indexPath.row) {
     
        case (0,1):
            self.showSexPicker()
            break
        case (0,2) : // 更改手机号码

            break
        case (2,0) :
            self.showUserLocationView()
            break
        case (2,1) :
            self.showInsdustryFuncationView()
            break
    
        default:
            
            self.showUserInfoVC(title, content: content, indexPath: indexPath)
            
            break
        }
        
    }
    
    func showUserInfoVC( _ title : String, content : String ,indexPath : IndexPath) {
        
        let viewController              =  ModifyUserinfoViewController()
        viewController.titleStr         = title
        viewController.indexPath        = indexPath
        viewController.contentStr       = content
        viewController.delege           = self
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(17.0)
    }
 
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.separatorInset = UIEdgeInsets.zero
        
    }
    
}

// MARK: - 和上传头像拍照相关的方法
extension BKEditingBusinessCardViewController : CYPhotoNavigationControllerDelegate , UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
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
    func uploadImageToAliCloudServer(_ image : UIImage) {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)

        let width               = KScreenWidth*3.0
        let height              = KScreenHeight*3.0
        let minx                = min(width, height)
        let smallImage          = image.withImage(image, scaledTo: CGSize(width:minx,height:minx))
      
        BKAliCloudUploadManager.manager.asyncUploadImage(smallImage , completion: {[weak self] (imageFileNames,finished) in
                HUD.hide(animated: true)
                self?.imageArray.removeAll()
                self?.imageArray = imageFileNames;
                if (self?.imageArray.count)! > 0 {
                    self?.addImageButtton?.setImage(smallImage, for: .normal)
                    self?.updateUserInfo()
                } else {
                    UnitTools.addLabelInWindow("上传部落头像失败,请重试", vc: self)
                }
            
            })
        
    }

    //MARK: CYPhotoNavigationControllerDelegate
    func cyPhotoNavigationController(_ controller: CYPhotoNavigationController?, didFinishedSelectPhotos result: [CYPhotosAsset]?) {
        
        let photosAsset = (result?.last)! as CYPhotosAsset
        let image       = photosAsset.originalImg
        self.uploadImageToAliCloudServer(image!)
        
    }
    
    // MARK: - UIImagePickerControllerDelegate , UINavigationControllerDelegate
    
    //点击UIImagePickerController 取消按钮时隐藏个人中心nav
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let type :NSString        = info["UIImagePickerControllerMediaType"] as! NSString
        if(type.isEqual(to: "public.image")) {
            picker.dismiss(animated: true, completion:nil)
            let image :UIImage  = info["UIImagePickerControllerEditedImage"] as! UIImage
            self.uploadImageToAliCloudServer(image)
        }
        
    }
}


// MARK: - UserinfoModifyDelegate

extension BKEditingBusinessCardViewController : UserinfoModifyDelegate {
    
    func didFinishedExchangeInfo(_ text : String,indexPath : IndexPath) {
        self.reloadSubTitle(text, indexPath: indexPath)
    }
    
}


// MARK: - BKIndustryfunctionViewDelegate

extension BKEditingBusinessCardViewController : BKIndustryfunctionViewDelegate {
    
    func industryfunctionViewDidFinishedSelect(_ insdutryView : BKIndustryfunctionView , industryfunction : String?, itemUids : String?) {
        self.industyItems           = itemUids
        self.reloadSubTitle(industryfunction!, indexPath: IndexPath(row: 1, section: 2))
    }
}

