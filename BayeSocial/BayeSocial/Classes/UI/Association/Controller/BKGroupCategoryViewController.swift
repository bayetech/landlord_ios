//
//  BKGroupCategoryViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/26.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

class BKGroupCategory : RLMObject {
    dynamic var name : String?
    dynamic var uid :String?
    dynamic var avatar : String?
    override class func primaryKey() -> String? {
        return "uid"
    }
    
}

@objc protocol BKGroupCategoryViewControllerDelegate : NSObjectProtocol {
     @objc optional func didSelectGroupCategorys(_ viewController : BKGroupCategoryViewController , category :BKGroupCategory)
}

/// 选择群分类
class BKGroupCategoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.loadDatas()
    }
    weak var delegate : BKGroupCategoryViewControllerDelegate?
    var grouopCategorys : [BKGroupCategory] = [BKGroupCategory]()
    func setup() {
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
    }
    
    func  loadDatas() {
       
        // 先读取本地数据库的内容
        self.grouopCategorys  = BKRealmManager.shared().readGroupCategorys()
        weak var weakSelf = self
        BKNetworkManager.getOperationReqeust(KURL_Chat_group_categories, params: nil, success: {[weak self] (result) in
            
                let json                    = result.value
                let chat_group_categories   = json["chat_group_categories"]?.arrayValue
                if chat_group_categories    != nil {
                    
                    self?.grouopCategorys.removeAll()
                    for json in chat_group_categories! {
                        let groupCategory       = BKGroupCategory()
                        groupCategory.uid       = json["uid"].stringValue
                        groupCategory.avatar    = json["avatar"].stringValue
                        groupCategory.name      = json["name"].stringValue
                        self?.grouopCategorys.append(groupCategory)
                        BKRealmManager.shared().insert(groupCategory)
                    }
                    
                    weakSelf?.tableView.reloadData()
                    
                } else  {
                     UnitTools.addLabelInWindow("获取部落分类失败!", vc: self)
                }

            }) { (result) in
                UnitTools.addLabelInWindow(result.errorMsg, vc: weakSelf)
        }
        
    }
    
    
    
    lazy var tableView : UITableView = {
        let tableView            = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(UINib(nibName: "BKGroupCategoryViewCell", bundle: nil), forCellReuseIdentifier: "BKGroupCategoryViewCell")
        tableView.delegate       = self
        tableView.dataSource     = self
        return tableView
    }()

    override func viewDidLayoutSubviews() {
        self.tableView.separatorInset = UIEdgeInsets.zero
    }
    

    
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKGroupCategoryViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.grouopCategorys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell                = tableView.dequeueReusableCell(withIdentifier: "BKGroupCategoryViewCell") as! BKGroupCategoryViewCell
        let category            = self.grouopCategorys[indexPath.row]

        cell.titleLabel.text    = category.name

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category    = self.grouopCategorys[indexPath.row]
        self.delegate?.didSelectGroupCategorys?(self, category: category)
        let _           =  self.navigationController?.popViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
    }

    
}
