//
//  BKShowRedPacketView.swift
//  BayeSocial
//
//  Created by dzb on 2016/12/30.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Spring
import SwiftyJSON

@objc enum BKShowRedPacketType : Int {
    case open // 可以打开
    case timeOut // 红包超过24小时
    case complete // 领完了
}

/// BKShowRedPacketViewDelegate
@objc protocol BKShowRedPacketViewDelegate : NSObjectProtocol {
    
    /// 视图已经消失
    @objc optional func showRedPacketViewDismiss(_ view :BKShowRedPacketView)
    
    /// 拆红包
    @objc optional func showRedPacketViewSeparateButtonClick(_ view :BKShowRedPacketView)
    
    /// 看看大家手气
    @objc optional func showRedPacketViewLucklabelClick(_ redpacketId : String,didOpenRedPacket : Bool)
    
}

/// 显示红包视图
class BKShowRedPacketView: UIView , CAAnimationDelegate {
    var contentView : SpringView        = SpringView()
    var backgroundView : UIView         = UIView()
    var imageView : UIImageView         = UIImageView()
    var customer : [String :Any]        = [String:Any]() {
        didSet {
            
            let json                = JSON(customer).dictionaryValue
            let name : String       = json["name"]?.stringValue ?? "匿名用户"
            let avatar : String     = json["avatar"]?.stringValue ?? ""
            nicknameLabel.text      = name
            avatarImageView.kf.setImage(with: URL(string :avatar), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    var message : String? {
        didSet {
            textLabel.text = message;
        }
    }
    var showLuckLabel : Bool = false {
        didSet {
            // 默认不显示红包查看我的手气
            luckLabel.isHidden = showLuckLabel
        }
    }
    var showType : BKShowRedPacketType  = .open {
        
        didSet {
            
            imageView.image                         =  UIImage(named: "redpacket_no separate")
            separateButton.isHidden                 = showType != .open
            if showType                             != .open {
                luckLabel.snp.updateConstraints({[weak self] (make) in
                    make.centerX.equalTo((self?.imageView)!)
                    make.bottom.equalTo((self?.imageView.snp.bottom)!).offset(-CYLayoutConstraintValue(47.0))
                })
            }
            
        }
        
    }
    var redPacketId : String?
    var avatarImageView : UIImageView   = UIImageView()
    var nicknameLabel : UILabel         = UILabel()
    var textLabel : UILabel             = UILabel()
    var luckLabel : UILabel             = UILabel()
    var separateButton : SpringButton   = SpringButton(type: .custom)
    weak var delegate : BKShowRedPacketViewDelegate?
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
         contentView.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.snp.top)!).offset(CYLayoutConstraintValue(127.0))
            make.centerX.equalTo(self!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(305.0), height: CYLayoutConstraintValue(417.5)))
        }
        // 红包视图
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.contentView)!)
        }
        
        // 头像
        imageView.addSubview(avatarImageView)
        avatarImageView.image = KCustomerUserHeadImage
        avatarImageView.setCornerRadius(CYLayoutConstraintValue(20.0))
        avatarImageView.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.imageView.snp.top)!).offset(CYLayoutConstraintValue(53.5))
            make.centerX.equalTo((self?.imageView)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(40.0), height: CYLayoutConstraintValue(40.0)))
        }
        
        // 昵称
        imageView.addSubview(nicknameLabel)
        nicknameLabel.font          = CYLayoutConstraintFont(15.0)
        nicknameLabel.textAlignment = .center
        nicknameLabel.textColor     = UIColor.colorWithHexString("#DCBC83")
        nicknameLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.avatarImageView.snp.bottom)!).offset(CYLayoutConstraintValue(10.0))
            make.left.right.equalTo((self?.imageView)!)
        }
        
        // 文字内容
        imageView.addSubview(textLabel)
        textLabel.font          = CYLayoutConstraintFont(23.0)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        textLabel.textColor     = UIColor.colorWithHexString("#FFD4B1")
        textLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.nicknameLabel.snp.bottom)!).offset(CYLayoutConstraintValue(31.0))
            make.left.equalTo((self?.imageView.snp.left)!).offset(CYLayoutConstraintValue(10.0))
            make.right.equalTo((self?.imageView.snp.right)!).offset(-CYLayoutConstraintValue(10.0))
        }
        
        /// 看看大家手气
        imageView.addSubview(luckLabel)
        luckLabel.font          = CYLayoutConstraintFont(14.0)
        luckLabel.textAlignment = .center
        luckLabel.textColor     = UIColor.colorWithHexString("#FFD4B1")
        luckLabel.text          = "看看大家的手气》"
        luckLabel.addTarget(self, action: #selector(lucklabelClick))
        luckLabel.snp.makeConstraints {[weak self] (make) in
            make.centerX.equalTo((self?.imageView)!)
            make.bottom.equalTo((self?.imageView.snp.bottom)!).offset(-CYLayoutConstraintValue(19.0))
        }
        
        // 拆开的按钮
        imageView.addSubview(separateButton)
        imageView.isUserInteractionEnabled = true
        separateButton.addTarget(self, action: #selector(separateButtonClick(_:)), for: .touchUpInside)
        //open_redpacket_sel
        separateButton.setImage(UIImage(named:"open_redpacket"), for: .normal)
        separateButton.setImage(UIImage(named:"open_redpacket_sel"), for: .selected)

        separateButton.snp.makeConstraints {[weak self]  (make) in
            make.centerX.equalTo((self?.imageView)!)
            make.top.equalTo((self?.imageView.snp.top)!).offset(CYLayoutConstraintValue(243.0))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(100.0), height: CYLayoutConstraintValue(100.0)))
        }
        
      
        showAnimation()
        
    }
    
    func showAnimation() {
        
        contentView.animation       = "pop"
        contentView.animateFrom     = false
        contentView.duration        = 1.5
        contentView.animate()
        UnitTools.delay(0.8) { [weak self] () in
            self?.imageView.isUserInteractionEnabled = true
            self?.imageView.addTarget(self, action: #selector(self?.dismiss))
        }
    }
    
    @objc func dismiss() {
        
        
        UIView.animate(withDuration: 0.5, animations: {[weak self] () in
            self?.contentView.transform                  = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self?.contentView.alpha                      = 0.0
            self?.backgroundView.backgroundColor         = UIColor.clear
        }) {[weak self] (finshed) in
            self?.delegate?.showRedPacketViewDismiss?(self!)
            self?.removeFromSuperview()
        }
        
        
    }
    
    /// 拆红包的按钮
    @objc func separateButtonClick(_ btn : UIButton) {
        
        separateButton.isSelected             = true
        contentView.isUserInteractionEnabled  = false
        let animation                         = CABasicAnimation()
        animation.keyPath                     = "transform.rotation.y"
        animation.duration                    = 0.5
        animation.delegate                    = self
        animation.repeatCount                 = MAXFLOAT
        animation.isRemovedOnCompletion       = true
        animation.fromValue                   = NSNumber(value: 0.0)
        animation.toValue                     = NSNumber(value: 3.1415926)
        separateButton.layer.add(animation, forKey: "Animation")
        
        delegate?.showRedPacketViewSeparateButtonClick?(self)


    }
   
    /// 看大家手气
    @objc func lucklabelClick()  {
        delegate?.showRedPacketViewLucklabelClick?(self.redPacketId!, didOpenRedPacket: false)
        removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 拆红包动画结束后
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        separateButton.layer.removeAnimation(forKey: "Animation")
        dismiss()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    deinit {
        
        NJLog(self)
        
    }
}
