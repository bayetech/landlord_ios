//
//  RegiserFullUserInfoViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import IQKeyboardManagerSwift
import PKHUD
import CYPhotosKit

/// 注册完善用户资料控制器
class RegiserFullUserInfoViewController: UIViewController {

    var avatarImageView : UIImageView? { // 头像
        didSet {
            avatarImageView?.addTarget(self, action: #selector(uploadImage))
            avatarImageView?.setCornerRadius(37.5)
        }
    }
    weak var responseTextField : UITextField? // 获得第一响应的输入框
    var industyItems : String? // 行业职能
    var imageArray : [String]           = [String]() // 上传头像信息
    var textFields : [UITextField]      = [UITextField]() // 输入框集合
    var verifyCode : String             = "" // 验证码
    var password   : String             = "" // 密码
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.view.backgroundColor                               = UIColor.white
        IQKeyboardManager.sharedManager().enableAutoToolbar     = false
        
    }
    
    /// 姓名输入框内容发送了改变
    @objc func textDidChange(_ textField : UITextField) {
        var text = textField.text
        if (text?.length)! > 6 {
            text = text?.subString(to: 6)
        }
        textField.text = text
    }
    
    /// 退出键盘
    @objc func hiddenKeyboard() {
        for textField in textFields {
            textField.resignFirstResponder()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enableAutoToolbar     = true
    }
    
    func setup() {
        
        // 基本信息
        let titleLabel                                          = UILabel()
        titleLabel.textAlignment                                = .center
        titleLabel.text                                         = "基本信息"
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo(CYLayoutConstraintValue(108.0))
            make.centerX.equalTo((self?.view)!)
        }
        
        // 头像
        self.avatarImageView                           = UIImageView()
        self.avatarImageView?.image                    = UIImage(named: "user_unregister")
        self.view.addSubview((self.avatarImageView)!)
        self.avatarImageView?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(CYLayoutConstraintValue(16.0))
            make.centerX.equalTo((self?.view)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(75.0), height: CYLayoutConstraintValue(75.0)))
        })
        
        var lastLineView : UIView?
        var placeHolders : [String]                     = ["使用真实姓名方便好友找到你","请选择性别","请输入职位","请选择行业职能"]
        let placeholderAttribut                         = [NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#C8C8C8"),NSAttributedStringKey.font : CYLayoutConstraintFont(15.0)]
        // 创建四个输入框
        for i in 0..<4 {
            
            let textField                               = UITextField()
            textField.attributedPlaceholder             = NSAttributedString(string: placeHolders[i], attributes:placeholderAttribut)
            textField.borderStyle                       = .none
            textField.delegate                          = self
            textField.tag                               = i + 100
            self.view.addSubview(textField)
            self.textFields.append(textField)
            if i == 0 {
                textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            }
            textField.snp.makeConstraints({[weak self]  (make) in
                
                if lastLineView != nil {
                    make.top.equalTo((lastLineView?.snp.bottom)!).offset(CYLayoutConstraintValue(15.0))
                } else {
                    make.top.equalTo((self?.avatarImageView?.snp.bottom)!).offset(CYLayoutConstraintValue(15.0))
                }
                make.centerX.equalTo((self?.view)!)
                make.width.equalTo(CYLayoutConstraintValue(240.0))
            })
            
            // 添加遮罩的 button 是为了防止多输入框时 影响输入框响应的焦点,性别 和行业职能输入框不能够接受响应
            if i == 1 || i == 3 {
                let button = UIButton(type : .custom)
                textField.addSubview(button)
                if i == 1 {
                    button.addTarget(self, action: #selector(selectUserSex), for: .touchUpInside)
                } else {
                    button.addTarget(self, action: #selector(selectUserIndustry), for: .touchUpInside)
                }
                button.snp.makeConstraints({ (make) in
                    make.edges.equalTo(textField)
                })
                button.tag = i
            } else {
                addTextInputView(textField)
            }

            // 横线
            let lineView                                = UIView()
            lineView.backgroundColor                    = UIColor.colorWithHexString("#E8E8E8")
            self.view.addSubview(lineView)
            lineView.snp.makeConstraints({[weak self]  (make) in
                make.top.equalTo(textField.snp.bottom).offset(CYLayoutConstraintValue(10.0))
                make.centerX.equalTo((self?.view)!)
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(240.0), height: CYLayoutConstraintValue(1.0)))
            })
            lastLineView = lineView;
        }
        
        // 完成按钮
        let finishedButton                              = UIButton(type: .custom)
        finishedButton.setTitleColor(UIColor.white, for: .normal)
        finishedButton.backgroundColor                  = UIColor.black
        finishedButton.titleLabel?.font                 = CYLayoutConstraintFont(15.0)
        finishedButton.titleLabel?.textAlignment        = .center
        finishedButton.setTitle("完成", for: .normal)
        finishedButton.setCornerRadius(CYLayoutConstraintValue(18.75))
        finishedButton.addTarget(self, action: #selector(finishedButtonClick(_:)), for: .touchUpInside)
        self.view.addSubview(finishedButton)
        finishedButton.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((lastLineView?.snp.bottom)!).offset(CYLayoutConstraintValue(20.0))
            make.centerX.equalTo((self?.view)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(110.0), height: CYLayoutConstraintValue(37.5)))
        })
        
        // 返回按钮
        let backAction                                  = UIButton(type: .custom)
        backAction.setImage(UIImage(named : "loginmodule_back"), for: .normal)
        self.view.addSubview(backAction)
        backAction.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        backAction.snp.makeConstraints {[weak self] (make) in
            make.bottom.equalTo((self?.view.snp.bottom)!).offset(-CYLayoutConstraintValue(80.5))
            make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(48.0))
            make.size.equalTo(CGSize(width: 50.0, height: 50.0))
        }
        
    }
    
    func addTextInputView(_ textField : UITextField) {
        
        let view                        = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 30.0))
        view.backgroundColor            = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        textField.inputAccessoryView    = view
        
        let button                      = UIButton(type: .system)
        button.setTitle("完成", for: .normal)
        button.addTarget(self, action:#selector(hiddenKeyboard), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.bottom.right.equalTo(view)
            make.width.equalTo(50.0)
        }
        
        
    }
    
    @objc func backClick() {
       let _ =  self.navigationController?.popToRootViewController(animated: true)
    }
    
    /// 完成按钮点击事件
    @objc func finishedButtonClick(_ btn : UIButton) {
        
        let userName = self.textFields[0].text
        if (userName?.isEmpty)! {
            UnitTools.addLabelInWindow("姓名不能为空", vc: self)
            return
        }
        
        let sex      = self.textFields[1].text
    
        if (sex?.isEmpty)! {
            UnitTools.addLabelInWindow("性别不能为空", vc:  self)
            return
        }
        
        let companyPosition = self.textFields[2].text
        if (companyPosition?.isEmpty)! {
            UnitTools.addLabelInWindow("职位不能为空", vc: self)
            return
        }
        
        let industry        = self.textFields[3].text
        if (industry?.isEmpty)! {
            UnitTools.addLabelInWindow("行业职能不能为空", vc: self)
            return
        }
        
        var params : [String : String]          = [String : String]()
        params["name"]                          = userName ?? ""
        params["gender"]                        = sex ?? "男"
        params["company_position"]              = companyPosition ?? ""
        params["industry_function_item_uids"]   = self.industyItems ?? ""
        params["mobile"]                        =  BKCacheManager.shared.userRegisterMobile ?? ""
        params["password"]                      = self.password
        params["verify_code"]                   = self.verifyCode
        
        let avatar                              = self.imageArray.last
        if avatar != nil {
            params["avatar"]                    = avatar!
        }

        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.postOperationReqeust(baseURLPath + "customers/register", params: params, success: {[weak self] (success) in

            let json                            = success.value
            let return_code                     = json["return_code"]?.int ??  0
            let message                         = json["return_message"]?.string ?? "创建账号失败"
            if return_code != 201 {
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow(message, vc: self)
                return
            }
            
            UnitTools.addLabelInWindow("创建账号成功", vc:  self)
            self?.userShouldLoginInWhenCreatSuccess()
            
            }) {[weak self] (failure) in
                HUD.hide(animated: true)
                self?.view.isUserInteractionEnabled      = true
                UnitTools.addLabelInWindow("创建账号失败", vc:  self)
        }
        
    }
    
    /// 账号注册成功后 直接登录
    func userShouldLoginInWhenCreatSuccess() {
        // 用户登录
        let loginViewController             = self.navigationController?.viewControllers.first as! BKLoginViewController
        loginViewController.userLogin(with: BKCacheManager.shared.userRegisterMobile!, password: self.password)
    }

    /// 选择用户性别
    @objc func selectUserSex() {
        
        hiddenKeyboard()
        
        let _ = YepAlertKit.showAlertView(in: self, title: "选择性别", message: nil, titles: ["男","女"], cancelTitle: "取消", destructive: nil) {[weak self] (index) in
            if index != 0 {
                let sex = index == 1 ? "男" : "女"
                self?.textFields[1].text = sex
            }
        }
        
        
    }
    
    /// 选择用户的行业分类
    @objc func selectUserIndustry() {
     
        hiddenKeyboard()
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getOperationReqeust(KURL_Industry_functions, params: nil, success: {[weak self] (success) in
            HUD.hide(animated: true)

            let json                        = success.value
            let industry_functions          = json["industry_functions"]?.arrayValue
            
            let industryArray               = BKIndustryMainModel.industryWithArray(industry_functions!)
            
            let insdutryView                = BKIndustryfunctionView()
            insdutryView.delegate           = self
            insdutryView.industryArray      = industryArray
            self?.view.addSubview(insdutryView)
            insdutryView.snp.makeConstraints { (make) in
                make.edges.equalTo((self?.view)!)
            }
            
        }) { (failure) in
            
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow(failure.errorMsg, vc: nil)
        }
        
    }

}

// MARK: - 行业职能
extension RegiserFullUserInfoViewController : BKIndustryfunctionViewDelegate {
    
    func industryfunctionViewDidFinishedSelect(_ insdutryView: BKIndustryfunctionView, industryfunction: String?, itemUids: String?) {
        
        self.industyItems                   = itemUids
        self.textFields[3].text             = industryfunction
        
    }
    
}

// MARK: - UITextFieldDelegate
extension RegiserFullUserInfoViewController : UITextFieldDelegate {
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.responseTextField = textField
        if textField.tag == 101 {
            self.selectUserSex()
        } else if (textField.tag == 103) {
            self.selectUserIndustry()
        }
        
    }
    
}

// MARK: - 上传头像模块

extension RegiserFullUserInfoViewController : CYPhotoNavigationControllerDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func cyPhotoNavigationController(_ controller: CYPhotoNavigationController?, didFinishedSelectPhotos result: [CYPhotosAsset]?) {
        
        let photosAsset         = (result?.last)! as CYPhotosAsset
        let image               = photosAsset.originalImg
        self.uploadGroupAvatar(image!)
        
    }
    
    /// 上传头像
    @objc func uploadImage() {
     
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
        
        HUD.flash(.labeledRotatingImage(image: PKHUDAssets.progressCircularImage, title: nil, subtitle: "正在准备上传图片,请稍后..."), delay: 30.0)
        
        let width               = image.size.width
        let height              = image.size.height
        let minx                = min(width, height)
        let smallImage          = image.withImage(image, scaledTo: CGSize(width:minx,height:minx))
        
        BKAliCloudUploadManager.manager.asyncUploadImage(smallImage , completion: {[weak self] (imageFileNames,finished) in
            HUD.hide(animated: true)
            self?.imageArray.removeAll()
            self?.imageArray    = imageFileNames;
            if (self?.imageArray.count)! > 0 {
                self?.avatarImageView?.image = smallImage
            } else {
                self?.avatarImageView?.image = UIImage(named: "")
                UnitTools.addLabelInWindow("上传部落头像失败,请重试", vc: self)
            }
        })
        
    }
    
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
        }
        
    }
    
}
