//
//  YepShareView.swift
//  BayeSocial
//
//  Created by dzb on 2017/1/18.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Spring

struct ShareViewModel {
    
    var title : String?
    var url : String?
    var image : String?
    var desc : String?
    
    init(title : String?,url:String?,image : String?,desc : String?) {
        self.title      = title
        self.url        = url
        self.image      = image
        self.desc       = desc
    }
    
    
}

/// 构造微信分享 和 巴爷汇分享的业务模块

class YepShareModule  {
    
    /// 分享到微信 包含朋友圈和微信好友
    
    class func wechatShare(_ type : SSDKPlatformType,shareModel :ShareViewModel) {
        
        
        if !WXApi.isWXAppSupport() {
            UnitTools.addLabelInWindow("分享失败", vc:nil)
            return
        }
        
        let avatar                  = shareModel.image ?? ""
        let imageURL                = URL(string : avatar)
        let title                   = shareModel.title
        let context                 = shareModel.desc
        let url                     = URL(string: (shareModel.url)!)
        
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
    
}

class YepShareView: UIView {
  
    var contentView : SpringView = SpringView()
    var backgroundView : UIView  = UIView()
    var shareModel : ShareViewModel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 遮罩视图
        backgroundColor                 = UIColor.clear
        addSubview(backgroundView)
        backgroundView.backgroundColor  = UIColor.colorWithHexString("#000000", alpha: 0.4)
        backgroundView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo(self!)
        }
        
        // 确认视图
        addSubview(contentView)
        contentView.backgroundColor = UIColor.colorWithHexString("#F3F3F3")
        contentView.snp.makeConstraints {[weak self] (make) in
            make.bottom.left.equalTo(self!)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(218.5)))
        }
        
        // 标题
        let titleLabel              = UILabel()
        titleLabel.text             = "   分享"
        titleLabel.textColor        = UIColor.colorWithHexString("#333333")
        titleLabel.font             = UIFont.systemFont(ofSize: 15.0)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {[weak self] (make) in
            make.top.left.equalTo((self?.contentView)!)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(35.0)))
        }
        
        // view
        let view                                = UIView()
        view.backgroundColor                    = UIColor.white
        contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(131.5)))
        }

        for i in 0..<2 {
            
            let btn             = BKAdjustButton(type: .custom)
            btn.frame           = CGRect(x: CGFloat(i)*KScreenWidth*0.5, y: 0.0, width: KScreenWidth*0.5, height: CYLayoutConstraintValue(131.5))
            btn.setTitle(i == 0 ? "微信好友" : "朋友圈", for: .normal)
            btn.setTitleColor(UIColor.colorWithHexString("#646464"), for: .normal)
            btn.textAlignment   = .center
            btn.titleFont       = UIFont.systemFont(ofSize: 15.0)
            btn.setImage(i == 0 ? UIImage(named:"weixin") : UIImage(named:"timeline") , for: .normal)
            btn.tag             = i+100
            btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
            view.addSubview(btn)

        }
        
        
        // 取消按钮
        let cancelButton                        = UIButton(type: .custom)
        cancelButton.backgroundColor            = UIColor.white
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor.colorWithHexString("#333333"), for: .normal)
        cancelButton.addTarget(self, action: #selector(hideAnimation), for: .touchUpInside)
        cancelButton.titleLabel?.font           = UIFont.systemFont(ofSize: 15.0)
        cancelButton.titleLabel?.textAlignment  = .center
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo(view.snp.bottom).offset(1.0)
            make.left.right.bottom.equalTo(self!)
        }
        
        
        showAnimation()
        
    }
    
    /// 动画
    func showAnimation() {
        
        contentView.animation       = "squeezeUp"
        contentView.animateFrom     = false
        contentView.duration        = 0.5
        contentView.animate()

        
    }
    
    /// 点击了分享的按钮
    @objc func btnClick(_ btn :BKAdjustButton) {
        
        hideAnimation()
        
        let type : SSDKPlatformType = (btn.tag == 100) ? .subTypeWechatSession : .subTypeWechatTimeline
        YepShareModule.wechatShare(type, shareModel: self.shareModel!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let wechatBtn   = self.viewWithTag(100) as! BKAdjustButton
        
        let timeLineBtn = self.viewWithTag(101) as! BKAdjustButton
        
        let imageW      = CYLayoutConstraintValue(45.0)
        let imageH      = imageW
        let imageY      = CYLayoutConstraintValue(17.0)
        let imageX      = (wechatBtn.width-imageW)*0.5
        
        let titleX      = CGFloat(0.0)
        let titleW      = wechatBtn.width
        let titleY      = 17.0+imageH+imageY
        
        wechatBtn.imageViewFrame    = CGRect(x: imageX, y: imageY, width: imageW, height: imageH)
        timeLineBtn.imageViewFrame  = CGRect(x: imageX, y: imageY, width: imageW, height: imageH)

        wechatBtn.titleLabelFrame   = CGRect(x: titleX, y: titleY, width: titleW, height: 17.0)
        timeLineBtn.titleLabelFrame   = CGRect(x: titleX, y: titleY, width: titleW, height: 17.0)

    }
    
    deinit {
        NJLog(self)
        
    }
    
    @objc func hideAnimation() {
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
}
