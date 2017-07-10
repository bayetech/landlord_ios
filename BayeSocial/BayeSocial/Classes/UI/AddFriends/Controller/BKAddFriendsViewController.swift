//
//  BKAddFriendsViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/27.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 添加好友的控制器
class BKAddFriendsViewController: BKBaseViewController {
    
    lazy var tableView : UITableView = {
        let tableView               = UITableView(frame: CGRect.zero, style: .plain)
         tableView.delegate         = self
        tableView.dataSource        = self
        tableView.tableFooterView   = UIView()
        return tableView
    }()
    var shareView : YepShareView?
    lazy var addFriendHeadView : UIView =  {
         let headView                   = UIView()
         headView.backgroundColor       = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        return headView
    }()
    var isShowShareUserView : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
        loadDatas()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    var dataArray : [[String : String]] = [[String : String]]()
    
    /// 初始化UI
    func createUI() {
        
        self.title      = "添加好友"
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {[unowned self] (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right: 0.0))
        }
        
        self.tableView.tableHeaderView = addFriendHeadView
        addFriendHeadView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.tableView)
            make.left.equalTo(self.tableView)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(70.0)))
        }
        
        // 联系人输入框
        let inputTextField                      = UITextField()
        inputTextField.attributedPlaceholder    = NSAttributedString(string: "手机号／姓名", attributes: [NSForegroundColorAttributeName:UIColor.colorWithHexString("#8E8E93"),NSFontAttributeName : CYLayoutConstraintFont(15.0)])
        inputTextField.backgroundColor          = UIColor.white
        inputTextField.font                     = CYLayoutConstraintFont(15.0)
        inputTextField.delegate                 = self
        // 输入框左边的搜索小图标
        inputTextField.leftViewMode             = .always
        let leftView                            = UIButton(type :.custom)
        leftView.frame                          = CGRect(x: 10.0, y: 0.0, width: 60.0, height: CYLayoutConstraintValue(35.0))
        leftView.setImage(UIImage(named: "By_keyword_Search"), for: .normal)
        leftView.isUserInteractionEnabled       = false
        inputTextField.leftView                 = leftView

        self.addFriendHeadView.addSubview(inputTextField)
        inputTextField.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.addFriendHeadView.snp.top).offset(CYLayoutConstraintValue(20.0))
            make.left.right.equalTo(self.addFriendHeadView)
            make.height.equalTo(CYLayoutConstraintValue(35.0))
        }
        
        self.tableView.delayReload(with: 0.001)

//        // 我的二维码标示
//        
//        let mineQRCodeLabel                     = UILabel()
//        mineQRCodeLabel.font                    = CYLayoutConstraintFont(14.0)
//        mineQRCodeLabel.textColor               = UIColor.colorWithHexString("#616161")
//        mineQRCodeLabel.text                    = "我的二维码："
//        mineQRCodeLabel.addTarget(self, action: #selector(BKAddFriendsViewController.showMineQRCodeView))
//         self.addFriendHeadView.addSubview(mineQRCodeLabel)
//        mineQRCodeLabel.snp.makeConstraints {[unowned self] (make) in
//            make.top.equalTo(inputTextField.snp.bottom)
//            make.centerX.equalTo(self.addFriendHeadView)
//            make.bottom.equalTo(self.addFriendHeadView)
//        }
//        
//        // 二维码标示
//        let scanImageView                       = UIImageView()
//        scanImageView.image                     = UIImage.init(named: "addfriend_scan_icon")
//        self.addFriendHeadView.addSubview(scanImageView)
//        scanImageView.addTarget(self, action: #selector(BKAddFriendsViewController.showMineQRCodeView))
//        scanImageView.snp.makeConstraints { (make) in
//            make.left.equalTo(mineQRCodeLabel.snp.right).offset(CYLayoutConstraintValue(9.0))
//            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(23.0), height: CYLayoutConstraintValue(23.0)))
//            make.centerY.equalTo(mineQRCodeLabel)
//        }
        
        
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//    }
    
//    /// 展示我的二维码页面
//    func showMineQRCodeView() {
//        
//        guard self.isShowShareUserView != false else {
//            return
//        }
//        self.isShowShareUserView        = false
//
//        let userShareQRCodeView         = BKShareUserQRCodeView.viewFromNib() as! BKShareUserQRCodeView
//        self.view.addSubview(userShareQRCodeView)
//        userShareQRCodeView.delegate    = self
//        userShareQRCodeView.snp.makeConstraints {[unowned self] (make) in
//            make.edges.equalTo(self.view)
//        }
//    }
    func loadDatas() {
        
//        var dict1                   = [String : String]()
//        dict1["icon"]               = "addfriend_contact_icon"
//        dict1["title"]              = "手机联系人"
//        dict1["detail"]             = "邀请或添加手机通讯录中的联系人"

        var dict2                   = [String : String]()
        dict2["icon"]               = "adfriend_wechat_icon"
        dict2["title"]              = "微信联系人"
        dict2["detail"]             = "邀请微信联系人"
        
        
//        var dict3                   = [String : String]()
//        dict3["icon"]               = "addfriend_scanQRCode"
//        dict3["title"]              = "扫一扫"
//        dict3["detail"]             = "扫描二维码添加好友"
//        
//        self.dataArray.append(dict1)
        self.dataArray.append(dict2)
//        self.dataArray.append(dict3)

        self.tableView.reloadData()
        
    }
    
    /// 点击分享 
    func showShareView() {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getReqeust(baseURLPath + "recommendation/my_invitation", params: nil, success: {[weak self] (success) in
             
            HUD.hide(animated: true)
            let json                                                = success.value
             let  my_invitation                             = json["my_invitation"]?.dictionary
             guard my_invitation                           != nil else {
                UnitTools.addLabelInWindow("获取分享内容失败", vc: self)
                return
             }
            
            let title : String                              = (my_invitation!["title"]?.stringValue)!
            let description : String                        = (my_invitation!["description"]?.stringValue)!
            let image : String                              = (my_invitation!["image"]?.stringValue)!
            let url : String                                = (my_invitation!["url"]?.stringValue)!
            // 分享内容的实体
            let shareModel                                  = ShareViewModel(title: title, url: url, image: image, desc: description)
            self?.shareView = YepShareView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: KScreenHeight))
            self?.shareView?.shareModel                     = shareModel
            self?.view?.addSubview((self?.shareView)!)
            
            }) {[weak self] (failure) in
                UnitTools.addLabelInWindow("获取分享内容失败", vc: self)
        }
        

    }

    deinit {
        
        NJLog(self)
        
    }
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKAddFriendsViewController : UITableViewDataSource , UITableViewDelegate {
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
            cell?.selectionStyle            = .none
            // iconView
            let iconView                    = UIImageView()
            iconView.image                  = UIImage(named: "addfriend_scan_icon")
            iconView.tag                    = 100
            cell?.contentView.addSubview(iconView)
            iconView.snp.makeConstraints({ (make) in
                make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(23.0))
                make.centerY.equalTo((cell?.contentView)!)
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(35.0), height: CYLayoutConstraintValue(35.0)))
            })
        
            let titleLabel                  = UILabel()
            titleLabel.tag                  = 200
            titleLabel.font                 = CYLayoutConstraintFont(16.0)
            cell?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(iconView.snp.right).offset(CYLayoutConstraintValue(12.5))
                make.top.equalTo((cell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(18.5))
            }
            
            
            let subTitleLabel               = UILabel()
            subTitleLabel.tag               = 300
            subTitleLabel.font              = CYLayoutConstraintFont(14.0)
            cell?.contentView.addSubview(subTitleLabel)
            subTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo((titleLabel.snp.bottom)).offset(CYLayoutConstraintValue(5.0))
                make.left.equalTo(titleLabel.snp.left)
            }
            
        }
        
        let dict                            = self.dataArray[indexPath.row]
        let imageView                       = cell?.contentView.viewWithTag(100) as? UIImageView
        imageView?.image                    = UIImage(named: dict["icon"]!)
        // 标题
        let label                           = cell?.contentView.viewWithTag(200) as? UILabel
        label?.text                         = dict["title"]
        
        let subLabel                        = cell?.contentView.viewWithTag(300) as? UILabel
        subLabel?.text                      = dict["detail"]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            case  0 :
                self.showShareView()
                break
            default :
                
            break
        }
        
    }

    
}

//// MARK: - BKShareUserQRCodeViewDelegate
//extension BKAddFriendsViewController : BKShareUserQRCodeViewDelegate {
//    
//    /// 视图即将消失
//    func shareViewWillDisApper(_ shareView: BKShareUserQRCodeView) {
//        self.isShowShareUserView = true
//    }
//     
//    /// 点击了用户头像
//    func shareViewDidSelectHeadImageView(_ shareView : BKShareUserQRCodeView) {
//        
//        
//    }
//    
//    /// 点击了我的好友
//    func shareViewDidSelectMineFriendButton(_ shareView : BKShareUserQRCodeView) {
//        
//    }
//    
//    /// 点击了商友圈按钮
//    func shareViewDidSelectBusinessLineButton(_ shareView : BKShareUserQRCodeView) {
//        
//    }
//    
//    /// 点击了微信好友
//    
//    func shareViewDidSelectWechatTimelineButton(_ shareView : BKShareUserQRCodeView) {
//        
//        
//    }
//    
//    /// 点击了朋友圈按钮
//     func shareViewDidSelectWechatSessionButton(_ shareView : BKShareUserQRCodeView){
//        
//        
//        
//    }
//}

// MARK: - UITextFieldDelegate
extension BKAddFriendsViewController : UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    
        let searchVC                    = BKSearchContactViewController()
        searchVC.searchType             = .searchRemoteContact
        self.navigationController?.pushViewController(searchVC, animated: false)
        
        return false
    }

}
