
//
//  UserinfoModifyViewController.swift
//  Baye
//
//  Created by 张少康 on 15/10/14.
//  Copyright © 2015年 Bayekeji. All rights reserved.
//

import UIKit
@objc protocol UserinfoModifyDelegate : NSObjectProtocol {
	@objc optional func updateSuccess(_ indexPath: IndexPath)
    @objc optional func didFinishedExchangeInfo(_ text : String,indexPath : IndexPath)
}

/// 修改用户资料的输入框
class ModifyUserinfoViewController: UIViewController {
	
    var contentStrLabel: UITextField? {
        didSet {
            contentStrLabel?.clearButtonMode = .always
        }
    }
    
	var titleStr: String?
    var indexPath : IndexPath?
	var contentStr: String?
    weak var delege: UserinfoModifyDelegate?
	override func viewDidLoad() {
		super.viewDidLoad()
        
        setup()
        
	}
    
    private func setup() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"保存", style: .plain, target: self, action: #selector(modifyCurrentItem(_:)))
        
        self.navigationItem.title       = self.titleStr ?? ""
        
        self.view.backgroundColor       = UIColor.RGBColor(242.0, green: 242.0, blue: 242.0)
        
        let backgroundView              = UIView()
        backgroundView.backgroundColor  = UIColor.white
        self.view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.view.snp.top)!).offset(80.0)
            make.left.equalTo((self?.view.snp.left)!).offset(20.0)
            make.right.equalTo((self?.view.snp.right)!).offset(-20.0)
            make.height.equalTo(45.0)
        }
        
        
        self.contentStrLabel            = UITextField()
        backgroundView.addSubview(self.contentStrLabel!)
        self.contentStrLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo(backgroundView.snp.left).offset(10.0)
            make.right.equalTo(backgroundView.snp.right).offset(-10.0)
            make.center.equalTo(backgroundView)
        })
        
        self.contentStrLabel?.text      = self.contentStr ?? ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.contentStrLabel?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
	
    func modifyCurrentItem(_ sender: UIBarButtonItem) {
        
        self.contentStrLabel?.resignFirstResponder()
        if self.contentStrLabel?.text?.length == 0 {
            UnitTools.addLabelInWindow("请输入要修改的内容", vc: self)
            return
        }
        
        self.delege?.didFinishedExchangeInfo?((self.contentStrLabel?.text!)!, indexPath: self.indexPath!)
        let _ =  self.navigationController?.popViewController(animated: true)
        
    }
    
    func backButtonClick(_ sender: UIBarButtonItem) {
        let _ = self.navigationController?.popViewController(animated: true)
    }

}
