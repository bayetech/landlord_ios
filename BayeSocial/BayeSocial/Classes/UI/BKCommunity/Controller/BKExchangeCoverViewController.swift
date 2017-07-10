//
//  BKExchangeCoverViewController.swift
//  BayeSocial
//
//  Created by 董招兵 on 2017/2/13.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import PKHUD
import CYPhotosKit

@objc protocol BKExchangeCoverViewControllerDelegate : NSObjectProtocol {
    @objc optional func changeBackgroundImageSuccess(_ imageUrl : String)
}

/// 更换相册封面
class BKExchangeCoverViewController: BKBaseViewController , UITableViewDelegate , UITableViewDataSource {

    var tableView : UITableView = UITableView(frame: CGRect.zero, style: .grouped)
    var imageArray : [String] = [String]()
    weak var delegate : BKExchangeCoverViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets   = true
        self.leftTitle                              = "更换相册封面"
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!)
        }
        self.tableView.delegate                     = self
        self.tableView.dataSource                   = self
        self.tableView.tableFooterView              = UIView()
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell                    = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.selectionStyle    = .none
        }
        
        cell?.textLabel?.text = indexPath.row == 0 ? "从手机相册选择" : "拍一张"
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            pickimageFrowLibrary()
            break
        default:
            takePhotos()
        }
        
    }
    
}

extension BKExchangeCoverViewController :  CYPhotoNavigationControllerDelegate , UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    
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
        let photoNav                = UIImagePickerController()
        photoNav.delegate           = self
        photoNav.allowsEditing      = true
        photoNav.sourceType         = .camera
        self.present(photoNav, animated: true, completion: nil)
        
    }
    
    
    /// 上传头像
    func uploadImageToAliCloudServer(_ image : UIImage) {
        
        HUD.flash(.labeledRotatingImage(image: PKHUDAssets.progressCircularImage, title: nil, subtitle: "正在准备上传图片,请稍后..."), delay: 30.0)
        
        let width               = image.size.width
        let height              = image.size.height
        let minx                = min(width, height)
        let smallImage          = image.withImage(image, scaledTo: CGSize(width:minx,height:minx))

        
        BKAliCloudUploadManager.manager.asyncUploadImage(smallImage , completion: {[weak self] (imageFileNames,finished) in
            
            self?.imageArray.removeAll()
            self?.imageArray = imageFileNames;
            if (self?.imageArray.count)! > 0 {
                self?.updateUserConverImg()
            } else {
                UnitTools.addLabelInWindow("更改相册封面失败！", vc: self)
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
    
    /// 上传到阿里云成功后提交给服务器图片名
    func updateUserConverImg() {
        
        let img             = self.imageArray.last
        HUD.flash(.labeledRotatingImage(image: PKHUDAssets.progressCircularImage, title: nil, subtitle: "开始上传图片,请稍后..."), delay: 30.0)
        
        BKNetworkManager.patchOperationReqeust(baseURLPath + "hubs/background_image", params: ["image" : img!], success: {[weak self] (success) in
            
            HUD.hide(animated: true)
            
            let return_code     = success.value["return_code"]?.intValue ?? 0
            let return_message  = success.value["return_message"]?.stringValue ?? "更改相册封面失败！"
            guard return_code == 201 else {
                UnitTools.addLabelInWindow(return_message, vc: self)
                return
            }
            
            UnitTools.addLabelInWindow("更改相册封面成功", vc: self)
            let hub_background_image = success.value["hub_background_image"]?.stringValue ?? ""
            
            self?.delegate?.changeBackgroundImageSuccess?(hub_background_image)
                    
            self?.navigationController?.popViewControllerAnimated(true, delay: 0.5)
            
        }) { (failure) in
            
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow(failure.errorMsg, vc: self)

        }
        
    }
}
