//
//  BKBaseSearchViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/28.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 搜索内容的类型
///
/// - searchLocalContact:              搜索本地人脉
/// - searchRemoteContact              搜索远程服务端人脉
/// - searchLocalGroup                 搜索群组
/// - searchRemoteGroup                搜索远程服务端群组
enum BKSearchResultType : Int {
    case searchLocalContact = 0
    case searchRemoteContact
    case searchLocalGroup
    case searchRemoteGroup
}

/// 人脉和群组搜索的基类

class BKBaseSearchViewController : BKBaseViewController {
    
    var searchType : BKSearchResultType     = .searchLocalContact
    var tableView : UITableView             = UITableView(frame: CGRect.zero, style:.plain)
    var headView : UIView                   = UIView()
    var textField : UITextField             = BKSearchTextField(text: "")
    var searchButton : UIButton             = UIButton(type: .custom)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = true
        self.addHeadView()
        self.addTableView()
        
    }
    
    
    /// 添加头部视图
    func addHeadView() {
        
        self.headView.backgroundColor   = UIColor.white
        self.view.addSubview(self.headView)
        self.headView.snp.makeConstraints { (make) in
            make.top.left.equalTo(self.view)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(69.0)))
        }
        
        // 输入框
        self.headView.addSubview(self.textField)
        self.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        self.textField.delegate              = self
        self.textField.clearButtonMode       = .always
        self.textField.returnKeyType         = .search
        self.textField.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.headView.snp.top)!).offset(CYLayoutConstraintValue(27.0))
            make.left.equalTo((self?.headView.snp.left)!).offset(CYLayoutConstraintValue(45.0))
            make.height.equalTo(CYLayoutConstraintValue(35.0))
            make.right.equalTo((self?.headView.snp.right)!).offset(-CYLayoutConstraintValue(15.0))
        }
        
        // 返回按钮
        let backButton : BKAdjustButton         = BKAdjustButton(type: .custom)
        backButton.setImage(UIImage(named: "black_backArrow"), for: .normal)
        backButton.titleLabel?.font             = CYLayoutConstraintFont(15.0)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.headView.addSubview(backButton)
        backButton.frame                        = CGRect(x: CYLayoutConstraintValue(3.0), y:  CYLayoutConstraintValue(33.0), width: CYLayoutConstraintValue(35.0), height: CYLayoutConstraintValue(21.0))
        backButton.setImageViewSizeEqualToCenter(CGSize(width: CYLayoutConstraintValue(13.0), height: CYLayoutConstraintValue(21.0)))
        //        backButton.backgroundColor              = UIColor.RandomColor()
        //        backButton.imageView?.backgroundColor   = UIColor.RandomColor()
        ////
        //        backButton.snp.makeConstraints {[weak self] (make) in
        //            make.centerY.equalTo((self?.textField)!)
        //            make.left.equalTo((self?.headView.snp.left)!).offset(CYLayoutConstraintValue(15.0))
        //            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(13.0), height: CYLayoutConstraintValue(21.0)))
        //        }
        //
        
        //        // 搜索按钮
        //        self.headView.addSubview(self.searchButton)
        //        self.searchButton.titleLabel?.font      = CYLayoutConstraintFont(15.0)
        //        self.searchButton.setTitleColor(UIColor.black, for: .normal)
        //        self.searchButton.addTarget(self, action: #selector(searchButtonClick(_:)), for: .touchUpInside)
        //        self.searchButton.setTitle("搜索", for: .normal)
        //        self.searchButton.snp.makeConstraints {[weak self] (make) in
        //            make.centerY.equalTo((self?.textField)!)
        //            make.right.equalTo((self?.headView.snp.right)!).offset(-CYLayoutConstraintValue(9.0))
        //            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(31.0), height: CYLayoutConstraintValue(30.0)))
        //        }
        
        // 底部横线
        let lineView : UIView           = UIView()
        lineView.backgroundColor        = UIColor.RGBColor(216.0, green: 216.0, blue: 216.0)
        self.headView.addSubview(lineView)
        lineView.snp.makeConstraints {[weak self] (make) in
            make.bottom.left.right.equalTo((self?.headView)!)
            make.height.equalTo(CYLayoutConstraintValue(1.0))
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        self.textField.becomeFirstResponder()
    }
    
    func addTableView() {
        
        self.view.backgroundColor           = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        self.tableView.backgroundColor      = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        self.tableView.tableFooterView      = UIView()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.headView.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    /// 返回按钮
    @objc func backAction() {
        self.textField.resignFirstResponder()
        let _ = self.navigationController?.popViewController(animated: false)
    }
    
    
}

// MARK: - 输入框代理
extension BKBaseSearchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.startSeachText(self.textField.text!)
        return true
    }
    
    /// 输入内容发生了改变
    @objc fileprivate func textDidChange() {
        let text                = self.textField.text
        self.setupTextfieldInputText(text!)
    }

    
    /// 开始搜索
    func startSeachText(_ text : String) {
        
        self.textField.resignFirstResponder()
        if (self.textField.text?.isEmpty)! {
            return
        }
        
    }
    
    /// 根据输入的内容 进行查询本地数据库数据
    public func setupTextfieldInputText(_ string : String) {
        
        
    }
    
    
}
