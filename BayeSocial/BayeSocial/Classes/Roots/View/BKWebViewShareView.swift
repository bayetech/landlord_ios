//
//  BKWebViewShareView.swift
//  BayeSocial
//
//  Created by 董招兵 on 2017/2/9.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

@objc protocol BKWebViewShareViewDelegate {
    @objc optional func webviewShareViewDidSelectAtIndex(_ index :Int)
}

let K_ContentViewHeight : CGFloat = 200.0

/// 巴爷供销社webview工具条视图
class BKWebViewShareView: UIView {

    var contentView : UIView = UIView()
    var backgroundView : UIView = UIView()
    weak var delegate : BKWebViewShareViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContentView()
        showShareView()
        
    }
    
    /// 初始化UI
    func setupContentView() {
        
        // 遮罩视图
        backgroundColor                 = UIColor.clear
        addSubview(backgroundView)
        backgroundView.backgroundColor  = UIColor.colorWithHexString("#000000", alpha: 0.4)
        backgroundView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo(self!)
        }
        backgroundView.addTarget(self, action: #selector(hideShareView))

        // 内容视图
        self.addSubview(contentView)
        contentView.backgroundColor     = UIColor.RGBColor(234.0, green: 234.0, blue: 234.0)
        contentView.frame               = CGRect(x: 0.0, y: KScreenHeight, width: KScreenWidth, height:K_ContentViewHeight)
        
        // 标题label
        let titleLabel                  = UILabel()
        titleLabel.text                 = "网页由 wechat.bayekeji.com 提供"
        titleLabel.font                 = UIFont.systemFont(ofSize: 12.0)
        titleLabel.textAlignment        = .center
        titleLabel.textColor            = UIColor.colorWithHexString("#898989")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.contentView.snp.top)!)
            make.left.right.equalTo((self?.contentView)!)
            make.height.equalTo(20.0)
        }
        
        let scrollView                 = UIScrollView(frame:CGRect(x: 0.0, y: 20.0, width: KScreenWidth, height: 130.0))
        contentView.addSubview(scrollView)
        
        let titleArray = ["微信好友","朋友圈","刷新"]
        let imageArray = ["weixin","timeline","Action_Refresh"]
    
        for i in 0..<titleArray.count {
           
            let row                             = i / 4
            let col                             = i % 4
           
            let buttonW : CGFloat               = 60.0
            let buttonH : CGFloat               = 90.0
            let margin                          = (KScreenWidth-buttonW*4.0)*0.2
            let buttonX : CGFloat               = margin+CGFloat(col)*(margin+buttonW)
            let buttonY                         = 25.0+CGFloat(row)*(buttonH+margin);
            let button                          = BKAdjustButton(type: .custom)
            button.frame                        = CGRect(x: buttonX, y: buttonY, width: buttonW, height: buttonH)
            button.imageViewFrame               = CGRect(x: 0.0, y: 0.0, width: buttonW, height: buttonW)
            button.setImage(UIImage(named:imageArray[i]), for: .normal)
            button.titleLabelFrame              = CGRect(x: 0.0, y: buttonW+5.0, width: buttonW, height: buttonH-buttonW-5.0)
            button.setTitleColor(UIColor.black, for: .normal)
            button.setTitle(titleArray[i], for: .normal)
            button.titleLabel?.font             = UIFont.systemFont(ofSize: 13.0)
            button.titleLabel?.textAlignment    = .center
            button.tag                          = i+100
            button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
            scrollView.addSubview(button)
            
        }
        
        // 取消按钮
        let cancelButton : UIButton    = UIButton(type: .custom)
        cancelButton.backgroundColor   = UIColor.white
        cancelButton.addTarget(self, action: #selector(hideShareView), for: .touchUpInside)
        cancelButton.setTitle("取消", for:.normal)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.titleLabel?.textAlignment = .center
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints {[weak self] (make) in
            make.bottom.left.equalTo((self?.contentView)!)
            make.size.equalTo(CGSize(width: KScreenWidth, height: 50.0))
        }
        
        
        
        
    }
    
    @objc func buttonClick(_ btn : BKAdjustButton) {
        let index = btn.tag - 100
        delegate?.webviewShareViewDidSelectAtIndex?(index)
        hideShareView()
    }
    
    /// 隐藏视图
    @objc func hideShareView() {
        
        UIView.animate(withDuration: 0.3, animations: { () in
            self.contentView.setY(KScreenHeight)
        }) { [weak self] (finished) in
            self?.removeFromSuperview()
        }

        
    }
    
    /// 显示视图
    func showShareView() {
        
        self.isUserInteractionEnabled     = false
        UIView.animate(withDuration: 0.3, animations: {[weak self] () in
            self?.contentView.setY(KScreenHeight-K_ContentViewHeight)
        }) { [weak self] (finished) in
            self?.isUserInteractionEnabled = true
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NJLog(self)
    }
    
}
