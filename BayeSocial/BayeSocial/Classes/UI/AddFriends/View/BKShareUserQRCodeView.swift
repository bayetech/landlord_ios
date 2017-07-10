//
//  BKShareUserQRCodeView.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/27.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Kingfisher

@objc protocol BKShareUserQRCodeViewDelegate {
    
    /// 点击了用户头像
    @objc optional func shareViewDidSelectHeadImageView(_ shareView : BKShareUserQRCodeView)
    
    /// 点击了我的好友
    @objc optional func shareViewDidSelectMineFriendButton(_ shareView : BKShareUserQRCodeView)
    
    /// 点击了商友圈按钮
    @objc optional func shareViewDidSelectBusinessLineButton(_ shareView : BKShareUserQRCodeView)
    
    /// 点击了微信好友

    @objc optional func shareViewDidSelectWechatTimelineButton(_ shareView : BKShareUserQRCodeView)
    
    /// 点击了朋友圈按钮
    @objc optional func shareViewDidSelectWechatSessionButton(_ shareView : BKShareUserQRCodeView)
    /// 视图将要消失的时候
    @objc optional func shareViewWillDisApper(_ shareView : BKShareUserQRCodeView)
}

class BKShareUserQRCodeView: UIView {
    
    @IBOutlet weak var userShareView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius  = CYLayoutConstraintValue(25.0)
            avatarImageView.layer.masksToBounds = true
            avatarImageView.addTarget(self, action: #selector(BKShareUserQRCodeView.avatarImageViewClick))
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qRCodeImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var avatarImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var qRCodeImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var qRCodeImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userShareViewRight: NSLayoutConstraint!
    @IBOutlet weak var userShareViewLeft: NSLayoutConstraint!
    @IBOutlet weak var userShareViewBottom: NSLayoutConstraint!
    @IBOutlet weak var userShareViewTop: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewleft: NSLayoutConstraint!
    @IBOutlet weak var avatarImageViewTop: NSLayoutConstraint!
    @IBOutlet weak var nameLabelRight: NSLayoutConstraint!
    @IBOutlet weak var nameLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var nameLabelTop: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTop: NSLayoutConstraint!
    @IBOutlet weak var qRimageViewTop: NSLayoutConstraint!
    @IBOutlet weak var textLabelTop: NSLayoutConstraint!
    @IBOutlet weak var friendButtonLeft: NSLayoutConstraint!
    @IBOutlet weak var friendButtonTop: NSLayoutConstraint!
    @IBOutlet weak var friendButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var friendButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var businessButtonLeft: NSLayoutConstraint!
    @IBOutlet weak var wechatBtnLeft: NSLayoutConstraint!
    @IBOutlet weak var timeLineBtnleft: NSLayoutConstraint!
    
    var mineQrCodeImage : UIImage?{
        didSet {
            guard mineQrCodeImage != nil else {
                return
            }
            self.qRCodeImageView.image = mineQrCodeImage
        }
    }
    weak var delegate : BKShareUserQRCodeViewDelegate?
    var userInfo : UserInfo {
        get {
            return BK_UserInfo
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    
        self.userShareViewTop.updateConstraint(121.0)
        self.userShareViewBottom.updateConstraint(121.0)
        self.userShareViewLeft.updateConstraint(45.0)
        self.userShareViewRight.updateConstraint(45.0)

        self.avatarImageViewleft.updateConstraint(12.0)
        self.avatarImageViewTop.updateConstraint(27.0)
        self.avatarImageViewWidth.updateConstraint(50.0)
        self.avatarImageViewHeight.updateConstraint(50.0)
        
        self.nameLabelTop.updateConstraint(24.0)
        self.nameLabelLeft.updateConstraint(11.0)
        self.nameLabelRight.updateConstraint(10.0)
        
        self.titleLabelTop.updateConstraint(5.0)
        
        self.qRimageViewTop.updateConstraint(12.0)
        self.qRCodeImageViewWidth.updateConstraint(190.0)
        self.qRCodeImageViewHeight.updateConstraint(190.0)
        
        self.bottomViewHeight.updateConstraint(105.0)
        
        self.friendButtonTop.updateConstraint(21.0)
        self.friendButtonLeft.updateConstraint(19.0)
        self.friendButtonWidth.updateConstraint(44.0)
        self.friendButtonHeight.updateConstraint(44.0)

        self.businessButtonLeft.updateConstraint(24.0)
        self.wechatBtnLeft.updateConstraint(24.0)

        let avatar                  = self.userInfo.avatar ?? ""
        self.avatarImageView.kf.setImage(with: URL(string: avatar), placeholder: KCustomerUserHeadImage, progressBlock:nil, completionHandler: nil)
  
        self.nameLabel.text         = self.userInfo.name
        self.titleLabel.text        = String(format: "%@ %@", self.userInfo.company ?? "",self.userInfo.company_position)
        self.userShareView.addTarget(self, action: #selector(BKShareUserQRCodeView.dismissAnimation))
        self.showAnimation()
        
    
    }
    
    /// 创建我的二维码
    func createMineQRCode(with image : UIImage) {
        
        weak var weakSelf = self
        DispatchQueue.global().async {
            let msg                             = "bayefriend:\(KCustomAuthorizationToken.easemob_username)"
            // 我的二维码
            let image                           = BKGenerateQRCode.createQRCodeByString(msg, foregroundImage : BKGenerateQRCode.centerImage(image))
            DispatchQueue.main.async {
                weakSelf?.mineQrCodeImage       = image
            }
        }
    
    }
    
    /// 点击头像
    func avatarImageViewClick() {
        self.delegate?.shareViewDidSelectHeadImageView?(self)
        self.dismissAnimation()
    }
    
    func showAnimation() {
        
        self.userShareView.transform            = CGAffineTransform(scaleX: 0.5, y: 0.5)
        weak var weakSelf                       = self
        UIView.animate(withDuration: 0.25, animations: {
            weakSelf?.userShareView.alpha       = 1.0
            weakSelf?.alpha                     = 1.0
            weakSelf?.userShareView.transform   = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) {[unowned self] (finished) in
              UIView.animate(withDuration: 0.25, animations: { 
                self.userShareView.transform    = .identity
              })
        }
        
    }
    
    func dismissAnimation() {
        
        weak var weakSelf                       = self
        UIView.animate(withDuration: 0.5, animations: {
            weakSelf?.userShareView.transform   = CGAffineTransform(scaleX: 0.01, y: 0.01)
            weakSelf?.userShareView.alpha       = 0.0
            weakSelf?.alpha                     = 0.0
        }) { (finished) in
            weakSelf?.delegate?.shareViewWillDisApper?(self)
            weakSelf?.removeFromSuperview()
        }
        
    }
    
    
    /// 点击了底部四个按钮
    @IBAction func buttonClick(_ sender: UIButton) {
        
        switch sender.tag {
        case 10:
            self.delegate?.shareViewDidSelectMineFriendButton?(self)
            break
        case 11:
            self.delegate?.shareViewDidSelectBusinessLineButton?(self)
            break
        case 12 :
            self.shareQRCodeToWechat(type: SSDKPlatformType.subTypeWechatSession)
            self.delegate?.shareViewDidSelectWechatSessionButton?(self)
            break
        default:
            self.shareQRCodeToWechat(type: SSDKPlatformType.subTypeWechatTimeline)
            self.delegate?.shareViewDidSelectWechatTimelineButton? (self)
        }
        self.dismissAnimation()
    }
    
    func shareQRCodeToWechat(type : SSDKPlatformType) {
        
        let avatar                  = self.userInfo.avatar ?? ""
        
        let imageURL                = URL(string : avatar)
        
        let title                   = String(format: "我是巴爷汇的%@, 邀请你也来巴爷汇", (self.userInfo.name))
        
        let context                 = "我在巴爷汇"
        
        let url                     = URL(string: "bayekeji://")
   
        
        let params                  = NSMutableDictionary()
        params.ssdkSetupShareParams(byText: context,
                                                images : imageURL,
                                                url : url,
                                                title : title,
                                                type : SSDKContentType.auto)

        //2.进行分享
        ShareSDK.share(type, parameters: params) { (state, userData, contentEntity, error) in
            switch state {
                case .success :
                    UnitTools.addLabelInWindow("分享成功", vc: nil)
                break
                
                default :
                
                break
            }
            
        }

        
    }
    
    deinit {
        
        NJLog(self)
   
    
    }
    
    
}
