//
//  BKIndustryfunctionView.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/4.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

/// BKIndustryfunctionViewDelegate
@objc protocol BKIndustryfunctionViewDelegate : NSObjectProtocol {
    @objc optional func industryfunctionViewDidFinishedSelect(_ insdutryView : BKIndustryfunctionView , industryfunction : String?, itemUids : String?)
}

class BKIndustryfunctionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.showAnimation()
        
    }
    var industryArray : [BKIndustryMainModel]                       = [BKIndustryMainModel]() {
        didSet {
            self.reloadSectionOne()
        }
    }
    var backgroundView : UIView?
    var insdustryView : UIView?
    var leftTableView : UITableView?
    var rightTableView : UITableView?
    var secondIndustryArray : [BKIndustrySubModel] = [BKIndustrySubModel]()
    weak var delegate : BKIndustryfunctionViewDelegate?
    var cacheSelectIndustryModels : [String : BKIndustrySubModel]  =  [String : BKIndustrySubModel]()
    
    func setup() {

        self.backgroundView                     = UIView()
        self.backgroundView?.alpha              = 0.0
        self.backgroundView?.backgroundColor    = UIColor.black.withAlphaComponent(0.4)
        self.addSubview(self.backgroundView!)
        self.backgroundView?.snp.makeConstraints({[unowned self] (make) in
            make.edges.equalTo(self)
        })
        
        // 读取数据库中行业智能数据
        industryArray = BKRealmManager.shared().readInsdustryModels()
        self.addInsdustryView()
        
    }
    
    /// 切换行业职能二级分类
    func reloadSectionOne() {
        
        let industryMainModel   = self.industryArray.first
        if industryMainModel   != nil {
            
            BKRealmManager.beginWriteTransaction()
            
            industryMainModel?.isSelected   = true
            
            BKRealmManager.commitWriteTransaction()

            self.secondIndustryArray = getSubIndustryItems(industryMainModel!)
            
        }
        
        self.leftTableView?.reloadData()
        self.rightTableView?.reloadData()
        
    }
    
    /// 获取行业智能的二级分类
    func getSubIndustryItems(_ insdustryModel : BKIndustryMainModel) -> [BKIndustrySubModel] {
        
        let subIndustrys : [BKIndustrySubModel] = UnitTools.bk_RlmArrayAllObjects(rlmArray: insdustryModel.subIndustryItems, ojbType: BKIndustrySubModel())
        
        return subIndustrys
    }
    
    

    func addInsdustryView() {
        
        self.insdustryView                          = UIView()
        self.insdustryView?.backgroundColor         = UIColor.white
        self.insdustryView?.setCornerRadius(CYLayoutConstraintValue(15.0))

        self.addSubview(self.insdustryView!)
        self.insdustryView?.snp.makeConstraints({[unowned self] (make) in
            make.top.equalTo(self.snp.top).offset(CYLayoutConstraintValue(95.0))
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(325.0), height: CYLayoutConstraintValue(CYLayoutConstraintValue(437.0))))
        })
        
        // 左边的tabelView
        self.leftTableView = self.creatTableView()
        self.insdustryView?.addSubview(self.leftTableView!)
        self.leftTableView?.snp.makeConstraints {[unowned self] (make) in
            make.top.left.equalTo(self.insdustryView!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(145.0), height: CYLayoutConstraintValue(352.0)))
            make.bottom.equalTo(-CYLayoutConstraintValue(80.0))
        }
        
        // 右边的tableView
        self.rightTableView  = self.creatTableView()
        self.insdustryView?.addSubview(self.rightTableView!)
        self.rightTableView?.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.leftTableView!)
            make.left.equalTo((self.leftTableView?.snp.right)!)
            make.height.equalTo(self.leftTableView!)
            make.right.equalTo(self.insdustryView!)
        }
        
        // 确定按钮
        let sureButton  = UIButton(type: .custom)
        sureButton.backgroundColor = UIColor.colorWithHexString("#39BBA1")
        sureButton.setTitle("确定", for: .normal)
        sureButton.setTitleColor(UIColor.white, for: .normal)
        sureButton.addTarget(self, action: #selector(BKIndustryfunctionView.sureButtonClick), for: .touchUpInside)
        sureButton.setCornerRadius(CYLayoutConstraintValue(4.0))
        self.insdustryView?.addSubview(sureButton)
        sureButton.snp.makeConstraints { (make) in
            make.bottom.equalTo((self.insdustryView?.snp.bottom)!).offset(-CYLayoutConstraintValue(18.0))
            make.left.equalTo((self.insdustryView?.snp.left)!).offset(CYLayoutConstraintValue(12.5))
            make.right.equalTo((self.insdustryView?.snp.right)!).offset(-CYLayoutConstraintValue(12.5))
            make.height.equalTo(CYLayoutConstraintValue(44.0))
        }
        
        self.leftTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "LeftCell")
        self.rightTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "RightCell")

    }
    
    func showAnimation() {
        
        self.insdustryView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        weak var weakSelf            = self
        UIView.animate(withDuration: 0.25, animations: {
            weakSelf?.insdustryView?.alpha                  = 1.0
            weakSelf?.backgroundView?.alpha                 = 1.0
            weakSelf?.insdustryView?.transform              = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) {[unowned self] (finished) in
            UIView.animate(withDuration: 0.25, animations: {
                self.insdustryView?.transform = .identity
            })
        }
        
    }
    
    func dismissAnimation() {
        
        weak var weakSelf                       = self
        UIView.animate(withDuration: 0.25, animations: {
            weakSelf?.insdustryView?.transform   = CGAffineTransform(scaleX: 0.01, y: 0.01)
            weakSelf?.insdustryView?.alpha       = 0.0
            weakSelf?.backgroundView?.alpha      = 0.0
        }) { (finished) in
            weakSelf?.removeFromSuperview()
        }
     
        
    }
    /// 点击了确定按钮
    func sureButtonClick() {
        
        var insdustryfunction : String          = ""
        var itemUids          : [String]        = [String]()
        for (_,insdustyModel) in self.cacheSelectIndustryModels {
            insdustryfunction.append(insdustyModel.name!)
            insdustryfunction.append(" ")
            itemUids.append(insdustyModel.uid!)
        }
        
        if insdustryfunction.length > 0 {
            self.delegate?.industryfunctionViewDidFinishedSelect?(self, industryfunction: insdustryfunction, itemUids: UnitTools.arrayTranstoString(itemUids))
        }
        
        self.dismissAnimation()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        self.leftTableView?.separatorInset      = UIEdgeInsets.zero
        self.rightTableView?.separatorInset     = UIEdgeInsets.zero

    }
    
    func creatTableView() -> UITableView {
        
        let tableView                           = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate                      = self
        tableView.dataSource                    = self
        tableView.showsVerticalScrollIndicator  = false
        tableView.tableFooterView               = UIView()
        return tableView
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


    deinit {
        
        NJLog(self)
        
    }
}


// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKIndustryfunctionView : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.leftTableView {
            return self.industryArray.count
        } else {
            return self.secondIndustryArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.leftTableView {
            
            let cell                            = tableView.dequeueReusableCell(withIdentifier: "LeftCell")
            cell?.selectionStyle                = .none
            let industryModel                   = self.industryArray[indexPath.row]
            cell?.textLabel?.font               = CYLayoutConstraintFont(14.0)
            cell?.textLabel?.textAlignment      = .center
            cell?.textLabel?.text               = industryModel.name
            
            cell?.contentView.backgroundColor   = industryModel.isSelected ? UIColor.RGBColor(217.0, green: 217.0, blue: 217.0) : UIColor.white
            
            return cell!
            
        } else {
            
            let cell                            = tableView.dequeueReusableCell(withIdentifier: "RightCell")
            cell?.textLabel?.font               = CYLayoutConstraintFont(14.0)
            cell?.selectionStyle                = .none
            cell?.backgroundColor   = UIColor.colorWithHexString("#F3F3F3")
            let industryModel                   = self.secondIndustryArray[indexPath.row]
            cell?.textLabel?.textAlignment      = .left
            cell?.textLabel?.text               = industryModel.name
            
            // 选择的industry_checkbox
            let button                          = UIButton(type: .custom)
            button.setImage(UIImage(named: "industry_checkbox_sel"), for: .selected)
            button.setImage(UIImage(named: "industry_checkbox_nor"), for: .normal)
            button.frame                        = CGRect(x: 0.0, y: 0.0, width: CYLayoutConstraintValue(20.0), height: CYLayoutConstraintValue(20.0))
            button.tag                          = indexPath.row
            button.isUserInteractionEnabled     = false
            cell?.accessoryView                 = button
            
            button.isSelected                   = industryModel.isSelected
            
            return cell!
        }
        
    
    }
    
    func updateIndustryModelState(at indexPath : IndexPath,insdustryModel : BKIndustryMainModel) {
        
        for (idx,item) in self.industryArray.enumerated() {
            BKRealmManager.beginWriteTransaction()
            if indexPath.row == idx {
                item.isSelected = true
            } else {
                item.isSelected = false
            }
            BKRealmManager.commitWriteTransaction()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(44.0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.leftTableView {
           
            self.secondIndustryArray.removeAll()
            
            let industryModel               = self.industryArray[indexPath.row]
            self.updateIndustryModelState(at: indexPath, insdustryModel: industryModel)

            self.secondIndustryArray        = getSubIndustryItems(industryModel)
            self.rightTableView?.reloadData()
            self.leftTableView?.reloadData()
            self.cacheSelectIndustryModels.removeAll()

        } else {
            
            let insdustryModel          = self.secondIndustryArray[indexPath.row]
            
            BKRealmManager.beginWriteTransaction()
            insdustryModel.isSelected   = !insdustryModel.isSelected
            BKRealmManager.commitWriteTransaction()

            if insdustryModel.isSelected {
                self.cacheSelectIndustryModels[insdustryModel.uid!] = insdustryModel
            } else {
                self.cacheSelectIndustryModels.removeValue(forKey: insdustryModel.uid!)
            }
            
            if self.cacheSelectIndustryModels.count > 3 {
                BKRealmManager.beginWriteTransaction()
                insdustryModel.isSelected   = false
                BKRealmManager.commitWriteTransaction()
                self.cacheSelectIndustryModels.removeValue(forKey: insdustryModel.uid!)
                UnitTools.addLabelInWindow("用户行业职能最多只能选择3个", vc: nil)
                return
            }
            

            self.rightTableView?.reloadRows(at: [indexPath], with: .automatic)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.separatorInset = UIEdgeInsets.zero
    
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
}


/// 群分类的一级模型
class BKIndustryMainModel : RLMObject {
    
   dynamic var uid : String?
   dynamic var name : String?
   dynamic var isSelected : Bool   = false
   dynamic var subIndustryItems = RLMArray(objectClassName: BKIndustrySubModel.className())

    /// 设置主 Key
    open override class func primaryKey() -> String? {
        return "uid"
    }
   
    /// 便利构造方法 字典转模型
    convenience init(by json : JSON) {
        self.init()
        
        self.uid        = json["uid"].stringValue
        self.name       = json["name"].stringValue
        if let items     = json["items"].array {
            for item in items {
                let subIndustry         = BKIndustrySubModel(by: item)
                subIndustry.parentId    = uid
                self.subIndustryItems.add(subIndustry)
            }
        }
       
       
    }
    
    /// 便利构造方法 字典数组转模型数组
    class func industryWithArray(_ jsonArray :[JSON]) -> [BKIndustryMainModel] {
        var array : [BKIndustryMainModel]   = [BKIndustryMainModel]()
        for json in jsonArray {
            let industryModel               = BKIndustryMainModel(by: json)
            array.append(industryModel)
        }
        return array
    }

}

/// 行业职能二级分类
class BKIndustrySubModel: RLMObject {
    dynamic var uid : String?
    dynamic var name : String?
    dynamic var isSelected : Bool   = false
    dynamic var parentId : String?
    /// 设置主 Key
    open override class func primaryKey() -> String? {
        return "uid"
    }
    
    /// 便利构造方法 字典转模型
    convenience init(by json : JSON) {
        self.init()
        self.uid    = json["uid"].stringValue
        self.name   = json["name"].stringValue
    }
    
    
}




