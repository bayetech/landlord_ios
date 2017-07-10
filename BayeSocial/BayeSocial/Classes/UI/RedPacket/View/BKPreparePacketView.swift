//
//  BKPreparePacketView.swift
//  BayeSocial
//
//  Created by dzb on 2016/12/28.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import Spring

@objc protocol BKPreparePacketViewDelegate : NSObjectProtocol {
  @objc optional func sendPacketButtonClick()
}


class BKPreparePacketView: UIView {

    var contentView : SpringView    = SpringView()
    var backgroundView : UIView     = UIView()
    var imageView : UIImageView     = UIImageView()
    var titleLabel : UILabel        = UILabel()
    var coin_quantity : Int         = 0 {
        didSet {
            setupCoin(coin_quantity)
        }
    }
    var redPacketType : RedPacketType = .personal {
        didSet {
            countLabel.isHidden = redPacketType == .personal
        }
    }
    var coinLabel   : UILabel       = UILabel()
    var countLabel : UILabel        = UILabel()
    var redPacketCount : Int        = 0 {
        didSet {
            countLabel.text = "共\(redPacketCount)个"
        }
    }
    var sendButton : UIButton       = UIButton(type: .custom)
    var receiveName : String        = "准备发红包" {
        didSet {
            if receiveName != "准备发红包" {
                titleLabel.text         = String(format: "准备发给“%@”", receiveName)
            } else {
                titleLabel.text         = receiveName
            }
        }
    }
    var data : [String :Any] = [String :Any]()  {
        didSet {
            let json            = JSON(data).dictionaryValue
            redPacketCount      = json["quantity"]?.intValue ?? 1
            coin_quantity       = json["coin"]?.intValue ?? 1
        }
    }
    
    weak var delegate : BKPreparePacketViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 遮罩视图
        backgroundColor            = UIColor.clear
        addSubview(backgroundView)
        backgroundView.backgroundColor  = UIColor.colorWithHexString("#000000", alpha: 0.4)
        backgroundView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo(self!)
        }
        
        // 确认视图
        addSubview(contentView)
        contentView.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.snp.top)!).offset(CYLayoutConstraintValue(146.5))
            make.centerX.equalTo(self!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(325.0), height: CYLayoutConstraintValue(356.0)))
        }
        
        contentView.backgroundColor = UIColor.white
        contentView.setCornerRadius(CYLayoutConstraintValue(24.5))
        
        // 图片
        contentView.addSubview(imageView)
        imageView.image = UIImage(named: "preparePacketImage")
        imageView.snp.makeConstraints {[weak self] (make) in
            make.top.left.right.equalTo((self?.contentView)!)
            make.height.equalTo(CYLayoutConstraintValue(167.5))
        }
        
        // 标题 Label
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines                = 2
        titleLabel.font                         = CYLayoutConstraintFont(17.0)
        titleLabel.textAlignment                = .center
        titleLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.contentView.snp.top)!).offset(CYLayoutConstraintValue(32.0))
            make.left.right.equalTo((self?.contentView)!)
        }
        
        // 巴金 label
        contentView.addSubview(coinLabel)
        coinLabel.textAlignment                 = .center
        coinLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.contentView.snp.top)!).offset(CYLayoutConstraintValue(139.0))
            make.left.right.equalTo((self?.contentView)!)
        }
        
        // 设置巴金数量
        setupCoin(0)
        
        // 巴金数量 label
        contentView.addSubview(countLabel)
        countLabel.font                         = CYLayoutConstraintFont(24.0)
        countLabel.textAlignment                = .center
        countLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.coinLabel.snp.bottom)!).offset(CYLayoutConstraintValue(15.0))
            make.left.right.equalTo((self?.contentView)!)
        }
        
        // 发送按钮
        contentView.addSubview(sendButton)
        sendButton.setTitle("发送红包", for: .normal)
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.titleLabel?.font            = CYLayoutConstraintFont(17.0)
        sendButton.titleLabel?.textAlignment   = .center
        sendButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#FA5959"), forState: .normal)
        sendButton.setCornerRadius(CYLayoutConstraintValue(2.5))
        sendButton.addTarget(self, action: #selector(sendButtonClick(_:)), for: .touchUpInside)
        sendButton.snp.makeConstraints {[weak self] (make) in
            make.bottom.equalTo((self?.contentView.snp.bottom)!).offset(-CYLayoutConstraintValue(50.0))
            make.centerX.equalTo((self?.contentView)!)
            make.size.equalTo(CGSize(width:CYLayoutConstraintValue(285.0), height: CYLayoutConstraintValue(50.0)))
        }
        
        contentView.addTarget(self, action: #selector(dismiss))
        
        showAnimation()
        
    }
    
    func showAnimation() {
        
        contentView.animation   = "pop"
        contentView.animateFrom = false
        contentView.duration    = 1.5
        contentView.animate()
        
    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.5, animations: {[weak self] () in
            self?.contentView.transform                  = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self?.contentView.alpha                      = 0.0
            self?.backgroundView.backgroundColor         = UIColor.clear
        }) {[weak self] (finshed) in

            self?.removeFromSuperview()
        }
        
    }
    
    func setupCoin(_ count :Int) {
        
        let attributedString                    = NSMutableAttributedString(string: "\(count)", attributes: [NSFontAttributeName : CYLayoutConstraintFont(36.0)])
        attributedString.append(NSAttributedString(string: "巴金", attributes: [NSFontAttributeName : CYLayoutConstraintFont(24.0)]))
        coinLabel.attributedText                = attributedString
        
    }
    
    /// 发送红包按钮
    func sendButtonClick(_ btn : UIButton) {
        
        delegate?.sendPacketButtonClick?()
        
        dismiss()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NJLog(self)
        
    }
}
