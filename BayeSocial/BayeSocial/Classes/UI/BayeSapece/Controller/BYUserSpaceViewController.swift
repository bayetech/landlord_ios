//
//  BYUserSpaceViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

/// 巴爷供销社我的界面
class BYUserSpaceViewController: BKBaseViewController {

    var tableView: UITableView              = UITableView(frame: CGRect.zero, style: .grouped)
    var nicknameLabel : UILabel?
    var jobTitleLabel : UILabel?
    var companyLabel : UILabel?
    var headImageView : UIImageView?
    var scanImageBtn : UIButton?
    var editBtn : UIButton?
    var user : UserInfo?
//    var centerImage : UIImage? {
//        didSet {
//            guard centerImage != nil else {
//                return
//            }
////            self.saveUserQRCode()
//        }
//        
//    }
    var dataArray : [[[String : String]]] = [[[String : String]]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    func setup() {
      
        self.view.addSubview(self.tableView)
        self.tableView.delegate                     = self
        self.tableView.dataSource                   = self
        self.tableView.tableFooterView              = UIView()
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!)
        }
        
        self.addHeadView()
        self.loadDatas()
        self.user                                   = BKRealmManager.shared().readUserInformation()
        
        self.update()
    
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reqeusetUserInfo()
        
    }
    
    /// 请求个人资料信息
    func reqeusetUserInfo() {
        
        BKNetworkManager.getOperationReqeust(KURL_CustomersProfile, params: nil, success: {[weak self] (success) in
            
                let json                        = success.value
                if let profile                  = json["profile"]?.dictionaryValue {
                    
                    self?.user                  = UserInfo(with: profile)
                    self?.update()
                    updateUserInfo((self?.user)!)
                    
                }
            
            }) {[weak self] (failure) in
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
        }

    }
    
    /// 更新用户数据
    func update() {
        
        guard self.user != nil else {
            return
        }
        
        // 设置头像
        let avatar                          = self.user?.avatar ?? ""
        let url                             = URL(string: avatar) ?? nil

        self.headImageView?.kf.setImage(with: url, placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
      
        self.nicknameLabel?.text            = self.user?.name ?? ""
        self.jobTitleLabel?.text            = self.user?.company_position ?? ""
        self.companyLabel?.text             = self.user?.company ?? ""
        
    }
    
    /// 添加头部视图
    func addHeadView() {
        
        let headView                                    = UIView()
        headView.frame                                  = CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(185.0))
        headView.backgroundColor                        = UIColor.white
        self.tableView.tableHeaderView                  = headView
        
        // 昵称
        let nameLabel                                   = UILabel()
        nameLabel.text                                  = "Double小姐～"
        nameLabel.font                                  = CYLayoutConstraintFont(30.0)
        headView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headView.snp.top).offset(CYLayoutConstraintValue(38.0))
            make.left.equalTo(headView.snp.left).offset(CYLayoutConstraintValue(20.0))
            make.width.equalTo(CYLayoutConstraintValue(190.0))
        }
        self.nicknameLabel                              = nameLabel
        
        // 职业
        self.jobTitleLabel                              = UILabel()
        self.jobTitleLabel?.text                        = "UI DESIGNER"
        self.jobTitleLabel?.textColor                   = UIColor.colorWithHexString("#666666")
        self.jobTitleLabel?.font                        = CYLayoutConstraintFont(15.0)
        headView.addSubview(self.jobTitleLabel!)
        self.jobTitleLabel?.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(CYLayoutConstraintValue(5.0))
            make.left.width.equalTo(nameLabel)
        }
        // 公司
        self.companyLabel                              = UILabel()
        self.companyLabel?.text                        = "巴爷科技（上海）有限公司"
        self.companyLabel?.textColor                   = UIColor.colorWithHexString("#666666")
        self.companyLabel?.font                        = CYLayoutConstraintFont(15.0)
        headView.addSubview(self.companyLabel!)
        self.companyLabel?.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo((self.jobTitleLabel?.snp.bottom)!).offset(CYLayoutConstraintValue(5.0))
            make.left.width.equalTo(nameLabel)
        }
        // 头像
        self.headImageView                              = UIImageView()
        self.headImageView?.image                       = KCustomerUserHeadImage
        self.headImageView?.layer.cornerRadius          = CYLayoutConstraintValue(60.0)
        self.headImageView?.layer.masksToBounds         = true
        self.headImageView?.addTarget(self, action: #selector(headImageViewClick))
        headView.addSubview(self.headImageView!)
        self.headImageView?.snp.makeConstraints({ (make) in
            make.top.equalTo(headView.snp.top).offset(CYLayoutConstraintValue(34.0))
            make.right.equalTo(headView.snp.right).offset(-CYLayoutConstraintValue(12.0))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(120.0), height: CYLayoutConstraintValue(120.0)))
        })
        
//        // 我的二维码按钮
//        self.scanImageBtn                               = UIButton(type: .custom)
//        self.scanImageBtn?.setImage(UIImage(named : "Baye_QRCode"), for: .normal)
//        headView.addSubview(self.scanImageBtn!)
//        self.scanImageBtn?.snp.makeConstraints({[unowned self] (make) in
//            make.top.equalTo((self.companyLabel?.snp.bottom)!).offset(CYLayoutConstraintValue(20.0))
//            make.left.equalTo(headView.snp.left).offset(CYLayoutConstraintValue(20.0))
//            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(25.0), height: CYLayoutConstraintValue(25.0)))
//        })
//        
        // 编辑个人资料的按钮
        self.editBtn                                    = UIButton(type: .custom)
        self.editBtn?.setImage(UIImage(named : "Bate_editInfo"), for: .normal)
        headView.addSubview(self.editBtn!)
        self.editBtn?.snp.makeConstraints({[unowned self] (make) in
                make.top.equalTo((self.companyLabel?.snp.bottom)!).offset(CYLayoutConstraintValue(20.0))
                make.left.equalTo(headView.snp.left).offset(CYLayoutConstraintValue(20.0))
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(25.0), height: CYLayoutConstraintValue(25.0)))
        })
        
//        self.scanImageBtn?.addTarget(self, action: #selector(showMineQRCoceView), for: .touchUpInside)
        self.editBtn?.addTarget(self, action: #selector(BYUserSpaceViewController.editInformation), for: .touchUpInside)

    }
    
   
    /// 加载数据
    func loadDatas() {
        
        var dict1                   = [String : String]()
        dict1["icon"]               = "mine_bayeLine"
        dict1["title"]              = "我的巴圈"
        
//        var dict2                   = [String : String]()
//        dict2["icon"]               = "mine_order"
//        dict2["title"]              = "我的订单"
//        
//        var dict3                   = [String : String]()
//        dict3["icon"]               = "mine_wallet"
//        dict3["title"]              = "我的钱包"
//        
//        var dict4                   = [String : String]()
//        dict4["icon"]               = "mine_bayeasset"
//        dict4["title"]              = "巴爷资产"
//        
//        var dict5                   = [String : String]()
//        dict5["icon"]               = "mine_bayemedal"
//        dict5["title"]              = "巴爷勋章"
//        
//        var dict6                   = [String : String]()
//        dict6["icon"]               = "mine_sendGift"
//        dict6["title"]              = "送礼定制"
//        
//        var dict7                  = [String : String]()
//        dict7["icon"]               = "mine_team"
//        dict7["title"]              = "我的生产队"
        
        var dict8                   = [String : String]()
        dict8["icon"]               = "mine_setting"
        dict8["title"]              = "设置"
        
        self.dataArray.append([dict1])
        self.dataArray.append([dict8])

//        self.dataArray.append([dict1,dict2,dict3])
//        self.dataArray.append([dict4,dict5,dict6])
//        self.dataArray.append([dict7])
        self.tableView.reloadData()
        
    }
    
        
//    /// 展示我的二维码
//    func showMineQRCoceView() {
//        
//        let userShareQRCodeView             = BKShareUserQRCodeView.viewFromNib() as! BKShareUserQRCodeView
//        self.view.addSubview(userShareQRCodeView)
//        userShareQRCodeView.mineQrCodeImage = self.centerImage
//        userShareQRCodeView.delegate        = self
//        userShareQRCodeView.snp.makeConstraints {[unowned self] (make) in
//            make.edges.equalTo(self.view)
//        }
//        
//        
//    }
    
    /// 点击用户头像编辑个人资料
    @objc func headImageViewClick() {
        
        let userDetailViewController                                    = BKUserDetailViewController()
        userDetailViewController.hidesBottomBarWhenPushed               = true
        userDetailViewController.userId                                 = KCustomAuthorizationToken.easemob_username
        self.navigationController?.pushViewController(userDetailViewController, animated: true)

    }
    
    /// 编辑个人资料
    @objc func editInformation() {

          let editingViewController                                 = BKEditingBusinessCardViewController()
          editingViewController.hidesBottomBarWhenPushed            = true
          editingViewController.leftTitle = "编辑资料"
          self.navigationController?.pushViewController(editingViewController, animated: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }

}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BYUserSpaceViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataArray.count == 0 {
            return 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return section == 0 ? 3 : 1
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.accessoryType             = .disclosureIndicator
            cell?.selectionStyle            = .none
            // iconView
            let iconView                    = UIImageView()
            iconView.tag                    = 100
            cell?.contentView.addSubview(iconView)
            iconView.snp.makeConstraints({ (make) in
                make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(19.0))
                make.centerY.equalTo((cell?.contentView)!)
            })
            // 标题
            let titleLabel                  = UILabel()
            titleLabel.tag                  = 200
            titleLabel.text                 = "巴圈"
            titleLabel.font                 = CYLayoutConstraintFont(16.0)
            cell?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(iconView.snp.right).offset(CYLayoutConstraintValue(12.0))
                make.centerY.equalTo((cell?.contentView)!)
            }

        }
        
        let iconView                    = cell?.contentView.viewWithTag(100) as? UIImageView
        let titleLabel                  = cell?.contentView.viewWithTag(200) as? UILabel
        let array                       = self.dataArray[indexPath.section]
        let dict                        = array[indexPath.row]
        iconView?.image                 = UIImage(named: (dict["icon"]!))
        titleLabel?.text                = dict["title"]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(44.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(10.0)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            
            //我的巴圈
            let mineDynamicViewController                           = BKMineDynamicStateViewController()
            mineDynamicViewController.userId                        = KCustomAuthorizationToken.easemob_username
            mineDynamicViewController.userId                        =  self.user?.uid ?? ""
            mineDynamicViewController.hidesBottomBarWhenPushed      = true
            self.navigationController?.pushViewController(mineDynamicViewController, animated: true)
            
            break
        case (1,0):
            
            // 设置
            let settingViewController = BKSettingViewController()
            settingViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingViewController, animated: true)
            
            break
        default:
            
            break
        }
        
    }

}

// MARK: - BKShareUserQRCodeViewDelegate
extension BYUserSpaceViewController : BKShareUserQRCodeViewDelegate {
    
    
}

extension BYUserSpaceViewController {
    
    
    
}
