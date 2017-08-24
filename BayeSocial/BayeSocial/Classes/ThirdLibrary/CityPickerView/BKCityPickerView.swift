//
//  BKCityPickerView.swift
//  BayeSocial
//
//  Created by dzb on 2017/1/6.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias CityCompletion = (_ province : String?, _ city : String?,_ district : String?) -> Void

/// 城市选择器
class BKCityPickerView: UIView {

    let contentView : UIView        = UIView()
    let pickerView : UIPickerView   = UIPickerView(frame: CGRect(x: 0.0, y: 40.0, width: KScreenWidth, height: 220.0))
    let backgroundView : UIView     = UIView()
    let viewHeight : CGFloat        = 260.0
    let toolBar : UIView            = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 40.0))
    let titleLabel : UILabel        = UILabel()
    var title : String              = "城市选择器"
    var provinceArray               = [String]()
    var cityArray                   = [String]()
    var districtArray               = [String]()
    var _proIndex : Int             = 0
    var _cityIndex : Int            = 0
    var _distrIndex : Int           = 0
    var dataArray : [JSON]          = [JSON]()
    var cityDict : [String :JSON]?
    var currentProvince : String    = ""
    var currentCity : String        = ""
    var currentDistrict : String    = ""
    var selectCompletion : CityCompletion?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        /// 初始化 UI
        setupUI()
        
        // 添加工具条
        setupToolBarView()
        
        // 获取数据源
        loadDatas()
        
    }
    
    /// 初始化 UI
    fileprivate func setupUI() {
        
        // 遮罩视图
        backgroundColor                  = UIColor.clear
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo(self!)
        }
        
        // 确认视图
        addSubview(contentView)
        contentView.frame               = CGRect(x: 0.0, y: KScreenHeight, width: KScreenWidth, height: viewHeight)
        contentView.backgroundColor     = UIColor.white
        
    }
    
    /// 获取数据源
    fileprivate func loadDatas() {
        
        let patch : String      = Bundle.main.path(forResource: "Address.plist", ofType: nil)!
        let array               = NSArray(contentsOfFile: patch)
        let json                = JSON(array!).arrayValue
        self.dataArray          = json
        
        for obj in self.dataArray {
            let dict            = obj.dictionaryValue
            let key             = dict.keys.first!
            self.provinceArray.append(key)
        }
        
        currentProvince         = self.provinceArray[0]
        getCityArray(with: currentProvince)
        
        currentCity             = cityArray.first!
        currentDistrict         = districtArray.first!
        
        
    }
    
    /// 显示城市选择器
    func showInView(_ view : UIView,callBack:CityCompletion?) {
        
        selectCompletion  = callBack
        view.addSubview(self)
        // 显示动画
        showAnimation()
        
    }
    
    /// 获取选择的城市集合
    fileprivate func getCityArray(with province:String) {
        
        for obj in self.dataArray {
            let dict                        = obj.dictionaryValue
            let anyKey                      = dict.keys.first!
            if anyKey == province {
                cityDict                    = dict[province]?.dictionaryValue
                let cityKey                 = cityDict?.keys.first
                getDistrictArray(with: cityKey!)
                cityArray                   = (cityDict?.keys.reversed())!
            }
        }

    }
    
    /// 获取区域集合
    fileprivate func getDistrictArray(with city : String) {
        districtArray               = cityDict?[city]?.arrayObject as! [String]
    }
    
    // 添加工具条
    fileprivate func setupToolBarView() {
        
        contentView.addSubview(toolBar)
        toolBar.backgroundColor = UIColor.white
        
        // 取消的按钮
        let cancelButton        = UIButton(type: .roundedRect)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        toolBar.addSubview(cancelButton)
        cancelButton.snp.makeConstraints {[weak self] (make) in
            make.top.left.bottom.equalTo((self?.toolBar)!)
            make.width.equalTo(60.0)
        }
        
        // 确定按钮
        let sureButton          = UIButton(type: .roundedRect)
        sureButton.setTitle("确定", for: .normal)
        sureButton.addTarget(self, action: #selector(sureClick), for: .touchUpInside)
        toolBar.addSubview(sureButton)
        sureButton.snp.makeConstraints {[weak self] (make) in
            make.top.right.bottom.equalTo((self?.toolBar)!)
            make.width.equalTo(60.0)
        }
        
        // 标题
        toolBar.addSubview(titleLabel)
        titleLabel.text             = title
        titleLabel.textAlignment    = .center
        titleLabel.snp.makeConstraints {[weak self] (make) in
            make.center.equalTo((self?.toolBar)!)
        }
        // pickerView
        contentView.addSubview(pickerView)
        pickerView.showsSelectionIndicator  = true
        pickerView.backgroundColor          = UIColor.RGBColor(237.0, green: 237.0, blue: 237.0)
        pickerView.delegate                 = self
        pickerView.dataSource               = self
        
        
    }
    
    /// 取消按钮
    @objc fileprivate func cancelClick() {
        
        hideAnimation()
        
    }
    
    /// 确定按钮
    @objc fileprivate func sureClick() {
        
        self.selectCompletion?(currentProvince,currentCity,currentDistrict)
        hideAnimation()
        
    }
    
    /// 展示动画
    fileprivate func showAnimation() {
      
        UIView.animate(withDuration: 0.25, animations: {[weak self]  in
            self?.backgroundView.backgroundColor   = UIColor.colorWithHexString("#000000", alpha: 0.4)
            self?.contentView.setY(KScreenHeight-(self?.viewHeight)!)
        }) {[weak self] (finished) in
            self?.backgroundView.addTarget(self, action: #selector(self?.addTapAction(_:)))
        }
        
    }
    
    /// 隐藏动画
   fileprivate func hideAnimation() {
        
        UIView.animate(withDuration: 0.25, animations: {[weak self]  in
            self?.contentView.setY(KScreenHeight)
        }) {[weak self] (finished) in
            self?.removeFromSuperview()
        }
        
    }
    
   @objc fileprivate func addTapAction(_ tap:UITapGestureRecognizer) {
        hideAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

  
    }

}

extension BKCityPickerView : UIPickerViewDelegate , UIPickerViewDataSource {
    
    
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3
        }
    
    
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0:
                return provinceArray.count
            case 1 :
                return cityArray.count
            case 2 :
                return districtArray.count
            default:
                return 0
            }
        }
    
    
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch component {
        case 0:
            return provinceArray[row]
        case 1 :
            
            return cityArray[row]
            
        case 2 :
            return districtArray[row]
        default:
            return ""
        }
        
    }
    
    
     func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel             = UILabel()
        pickerLabel.numberOfLines   = 0
        pickerLabel.textAlignment   = .center
        pickerLabel.font            = UIFont.systemFont(ofSize: 12.0)
        pickerLabel.text            = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        
        return pickerLabel
    }
    
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            
            currentProvince     = self.provinceArray[row]
            getCityArray(with: currentProvince)
          
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
            
            
            currentCity         = cityArray.first!
            currentDistrict     = districtArray.first!
            

        } else if component == 1 {
            
            currentCity         = cityArray[row]
            getDistrictArray(with: currentCity)
            
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
            
            currentDistrict     = districtArray.first!

        } else if component == 2 {
            
            currentDistrict = districtArray[row]
            
        }
        
        
    }
 
    
}
