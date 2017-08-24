//
//  BKCreateGroupViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/25.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import PKHUD
import CYPhotosKit

/// 创建群聊直上传群头像和设置群名称

class BKCreateGroupViewController: UIViewController {

    lazy var addImageButtton : UIButton = {
        let btn                 = UIButton(type: .custom)
        btn.setImage(UIImage(named: "group_avatar"), for: .normal)
        btn.addTarget(self, action: #selector(BKCreateGroupViewController.addImageButtonClick), for: .touchUpInside)
        btn.layer.cornerRadius  = CYLayoutConstraintValue(60.0)
        btn.layer.masksToBounds = true
        
        return btn
    }()
    var imageArray : [String] = [String]()
    lazy var textField : UITextField = {
        let tf                       = UITextField()
        tf.attributedPlaceholder     = NSAttributedString(string: "请输入部落名称，最多15个字", attributes: [NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#C8C8C8"),NSAttributedStringKey.font : CYLayoutConstraintFont(16.0)])
        tf.addTarget(self, action: #selector(BKCreateGroupViewController.textDidChange), for: .editingChanged)
        tf.borderStyle                = .none
//        tf.delegate              = self
        return tf
    }()
    
    lazy var nextBtn : UIButton = {
        let btn                         = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(BKCreateGroupViewController.nextAction), for: .touchUpInside)
        btn.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#D8D8D8"), forState: .normal)
        btn.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#39BBA1"), forState: .selected)
        btn.layer.cornerRadius          = CYLayoutConstraintValue(3.0)
        btn.setTitle("下一步", for: .normal)
        btn.isUserInteractionEnabled    = false
        btn.layer.masksToBounds         = true
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.setup()
        
    }
    
    func setup() {
    
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.addImageButtton)
        self.addImageButtton.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(CYLayoutConstraintValue(100.0))
            make.centerX.equalTo(self.view)
            let size = CGSize(width: CYLayoutConstraintValue(120.0), height: CYLayoutConstraintValue(120.0))
            make.size.equalTo(size)
        }
        
        self.view.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(self.addImageButtton.snp.bottom).offset(CYLayoutConstraintValue(40.0))
            make.left.equalTo(self.view.snp.left).offset(CYLayoutConstraintValue(80.0))
            make.right.equalTo(self.view.snp.right).offset(-CYLayoutConstraintValue(80.0))
        }
        
        let lineView                = UIView()
        lineView.backgroundColor    = UIColor.colorWithHexString("#E7E7E7")
        self.view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(self.textField.snp.bottom).offset(CYLayoutConstraintValue(5.0))
            make.left.equalTo(self.view.snp.left).offset(CYLayoutConstraintValue(15.0))
            make.right.equalTo(self.view.snp.right).offset(-CYLayoutConstraintValue(15.0))
            make.height.equalTo(1.0)
        }
        
        self.view.addSubview(self.nextBtn)
        self.nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(20.0)
            make.left.equalTo(self.view.snp.left).offset(CYLayoutConstraintValue(20.0))
            make.right.equalTo(self.view.snp.right).offset(-CYLayoutConstraintValue(20.0))
            make.height.equalTo(CYLayoutConstraintValue(50.0))
        }

    }
    
    /// 下一步
    @objc func nextAction() {
        
        let avatar              = self.imageArray.last
        guard avatar != nil else {
            UnitTools.addLabelInWindow("请上传一张部落头像", vc: self)
            return
        }
        guard !(self.textField.text?.isEmpty)! else {
            UnitTools.addLabelInWindow("部落名称不能为空", vc: self)
            return
        }
        
        let fullInfoVC              = BKFullGroupInfoViewController()
        fullInfoVC.avatar           = avatar!
        fullInfoVC.groupname        = self.textField.text!
        self.navigationController?.pushViewController(fullInfoVC, animated: true)
        
    }
    
    /// 输入内容发生改变
    @objc func textDidChange() {
        
        var text                                = textField.text!
        let length                              = text.length
        
        if (length) > 15 {
            text = text.subString(to: 15)
        }
        self.textField.text                     = text
        self.nextBtn.isSelected                 = !text.isEmpty
        self.nextBtn.isUserInteractionEnabled   = self.nextBtn.isSelected
    }

    /// 上传群头像
    @objc func addImageButtonClick()  {

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
        
        let width               = image.size.width
        let height              = image.size.height
        let minx                = min(width, height)
        let smallImage          = image.withImage(image, scaledTo: CGSize(width:minx,height:minx))

        
        BKAliCloudUploadManager.manager.asyncUploadImage(smallImage ,completion: {[weak self] (imageFileNames,finished) in
            HUD.hide(animated: true)
            
            self?.imageArray.removeAll()
            self?.imageArray = imageFileNames;
            if self?.imageArray.count == 0 {
                UnitTools.addLabelInWindow("上传部落头像失败,请重试", vc: self)
            } else {
                self?.addImageButtton.setImage(smallImage, for: .normal)
            }
            
        })

    }
    
    deinit {
        NJLog(self)
    }
    
    
}


// MARK: - CYPhotoNavigationControllerDelegate
extension BKCreateGroupViewController : CYPhotoNavigationControllerDelegate {
    
    func cyPhotoNavigationController(_ controller: CYPhotoNavigationController?, didFinishedSelectPhotos result: [CYPhotosAsset]?) {
        
        let photosAsset = (result?.last)! as CYPhotosAsset
        let image       = photosAsset.originalImg
        self.uploadGroupAvatar(image!)


    }
    
}

// MARK: - UIImagePickerControllerDelegate , UINavigationControllerDelegate
extension BKCreateGroupViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
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


