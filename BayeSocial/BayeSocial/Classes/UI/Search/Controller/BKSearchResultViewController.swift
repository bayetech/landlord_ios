//
//  BKSearchResultViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/9.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 搜索人脉和群组的控制器
class BKSearchResultViewController: BKBaseViewController {
    
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var groupButtonRight: NSLayoutConstraint!
    @IBOutlet weak var contactButtonTop: NSLayoutConstraint!
    @IBOutlet weak var contactButtonLeft: NSLayoutConstraint!
    @IBOutlet weak var textFieldRight: NSLayoutConstraint!
    @IBOutlet weak var textFieldLeft: NSLayoutConstraint!
    @IBOutlet weak var textFieldTop: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonRight: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var chatgroupLabel: UILabel!
    @IBOutlet weak var groupButton: UIButton!
    var groupArray      : [BKChatGroupModel]    = [BKChatGroupModel]()
    var contactArray    : [BKCustomersContact]  = [BKCustomersContact]()
    
    lazy var tableView : UITableView = {
        let tableView               = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate          = self
        tableView.dataSource        = self
        tableView.tableFooterView   = UIView()
        return tableView
    }()
    
    @IBOutlet weak var contactLabelTop: NSLayoutConstraint!
    /// 选择了人脉的按钮
    @IBAction func contactButtonClick(_ sender: UIButton) {
        
        let searchContatcViewController             = BKSearchContactViewController()
        searchContatcViewController.searchType      = .searchLocalContact
        self.navigationController?.pushViewController(searchContatcViewController, animated: false)
        
    }
    
    /// 点击了群组的按钮
    @IBAction func chatGrouopClick(_ sender: UIButton) {
        let searchGroupViewController               = BKSearchGroupViewController()
        searchGroupViewController.searchType        = .searchLocalGroup
        self.navigationController?.pushViewController(searchGroupViewController, animated: false)
    }

    @IBAction func cancelButtonClick(_ sender: UIButton) {
        let _ = self.textField.resignFirstResponder()
        let _ =  self.navigationController?.popViewController(animated: false)
    }
    
    @IBOutlet weak var textField: BKSearchTextField! {
        didSet {
            textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
       
    }
    
    func setup() {
        
        self.textField.placeholder = "搜索"
        self.textField.becomeFirstResponder()
        
        self.textFieldTop.updateConstraint(32.0)
        self.textFieldLeft.updateConstraint(18.0)
        self.textFieldRight.updateConstraint(10.0)
        self.textFieldHeight.updateConstraint(35.0)
        
        self.cancelButtonRight.updateConstraint(9.0)
        self.cancelButtonWidth.updateConstraint(31.0)
        self.cancelButtonHeight.updateConstraint(30.0)
        
        self.contactButtonTop.updateConstraint(51.0)
        self.contactButtonLeft.updateConstraint(75.0)
        self.groupButtonRight.updateConstraint(75.0)
        
        self.contactLabelTop.updateConstraint(17.0)
        
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 90.0, left: 0.0, bottom: 0.0, right: 0.0))
        }
        self.tableView.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    /// 根据输入的内容 进行查询本地数据库数据
    func setupTextfieldInputText(_ string : String) {
        
        let text                                = string

        let isEmpty                             = text.isEmpty
        self.contactButton.isHidden             = !text.isEmpty
        self.groupButton.isHidden               = self.contactButton.isHidden
        self.chatgroupLabel.isHidden            = self.contactButton.isHidden
        self.contactLabel.isHidden              = self.contactButton.isHidden
        self.tableView.isHidden                 = !self.contactButton.isHidden
        
        guard !isEmpty else {
            return
        }
        
        
        self.contactArray =  BKRealmManager.shared().queryCustomerUser(byKeywords: text)
        
        self.groupArray =  BKRealmManager.shared().queryChatgroupsOrder(byKeywords: text)
        
        self.tableView.reloadData()

    }
    
    /// 输入内容发送改变的事件
    
    @objc func textDidChange() {
        
        self.setupTextfieldInputText(self.textField.text!)
    
    }
    
}


// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKSearchResultViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count  = section == 0 ? self.contactArray.count : self.groupArray.count
        return count
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
            iconView.setCornerRadius(22.5)

            cell?.contentView.addSubview(iconView)
            iconView.snp.makeConstraints({ (make) in
                make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(23.0))
                make.centerY.equalTo((cell?.contentView)!)
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(45.0), height: CYLayoutConstraintValue(45.0)))
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
        
        var avatar : String?
        var name   : String?
        var desc   : String?
        if (indexPath.section == 0) {
            
            let contact         = self.contactArray[indexPath.row]
            avatar              = contact.avatar
            name                = contact.name
            desc                = contact.company
        
        } else {
            
            let chatGroup       = self.groupArray[indexPath.row]
            avatar              = chatGroup.avatar
            name                = chatGroup.groupname
            desc                = chatGroup.desc
            
        }
        
        
        let imageView                           = cell?.contentView.viewWithTag(100) as? UIImageView
        if avatar != nil {
            imageView?.kf.setImage(with: URL(string: (avatar)!), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        // 标题
        let label                               = cell?.contentView.viewWithTag(200) as? UILabel
        label?.text                             = name
        
        let subLabel                            = cell?.contentView.viewWithTag(300) as? UILabel
        subLabel?.text                          = desc
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(67.5)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var conversationId = ""
        var chatTitle = ""
        if (indexPath.section == 0) {
            let contactModel    = self.contactArray[indexPath.section]
            conversationId      = contactModel.uid
            chatTitle           = contactModel.name
        } else {
            let groupModel      = self.groupArray[indexPath.section]
            conversationId      = groupModel.groupid ?? ""
            chatTitle           = groupModel.groupname!
        }
        let user                = UserInfo()
        user.uid                = conversationId
        user.name               = chatTitle
        
        self.textField.text     = ""
        self.setupTextfieldInputText(self.textField.text!)
        self.textField.resignFirstResponder()

        EMIMHelper.shared().hy_chatRoom(withConversationChatter: conversationId, soureViewController: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let count  = section == 0 ? self.contactArray.count : self.groupArray.count
        guard count != 0 else {
            return 0.0
        }
        return CYLayoutConstraintValue(44.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let count  = section == 0 ? self.contactArray.count : self.groupArray.count
        guard count != 0 else {
            return nil
        }
        
        var headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headView")
        if (nil == headView) {
            
            headView            = UITableViewHeaderFooterView(reuseIdentifier: "headView")
            let label           = UILabel()
            label.textColor     = UIColor.colorWithHexString("#333333")
            label.font          = CYLayoutConstraintFont(17.0)
            label.tag           = 100
            headView?.contentView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.left.equalTo((headView?.contentView.snp.left)!).offset(CYLayoutConstraintValue(15.0))
                make.top.bottom.right.equalTo((headView?.contentView)!)
            })
            
        }
        
        let label               = headView?.contentView.viewWithTag(100) as! UILabel
        label.text              = section == 0 ? "我的人脉" : "我的部落"
        label.textColor         = UIColor.gray
        
        return headView
    }
    
    
}
