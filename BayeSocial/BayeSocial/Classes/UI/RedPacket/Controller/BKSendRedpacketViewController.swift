//
//  BKBaseRedpacketViewController.swift
//  BayeSocial
//
//  Created by dzb on 2016/12/26.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import PKHUD
import SwiftyJSON
import Alamofire

@objc enum RedPacketType : Int {
    case personal = 0 // 个人
    case group  // 群组
}

@objc protocol SendRedPacketCellDelegate : NSObjectProtocol {
    @objc optional func coinQuantityTextDidChange(_ text : String , section : Int,sendRedPacketSelect : Bool)
    @objc optional func otherTextDidChange(_ text : String , section : Int)
    @objc optional func textDidEndEditing(_ text : String , section : Int)
}

class SendRedPacketCell : UITableViewCell , UITextFieldDelegate {
    weak var delegate : SendRedPacketCellDelegate?
    var data : [String : String]? {
        didSet {
            
            self.titleLabel?.text                   = data?["title"]
            self.textField?.attributedPlaceholder   = NSAttributedString(string: data!["placeholder"]!, attributes: [NSFontAttributeName : CYLayoutConstraintFont(17.0),NSForegroundColorAttributeName : (self.color)])
            if indexPath?.section == 0  {
                
                if redPacketType == .group {
                    let rightLabel                       = UILabel(frame : CGRect(x: 0.0, y: 0.0, width: 30.0, height: 20.0))
                    rightLabel.text                      = "个"
                    rightLabel.font                      = self.titleLabel?.font
                    rightLabel.textAlignment             = .center
                    textField?.rightView                 = rightLabel
                    textField?.rightViewMode             = .always
                }
               
                textField?.keyboardType              = .numberPad
            } else {
                textField?.rightView                 = nil
                textField?.rightViewMode             = .never
            }
            
            if indexPath?.section == 1 && redPacketType == .group {
                textField?.keyboardType              = .numberPad
            }
            
            
        }
        
        
    }
    var titleLabel : UILabel?
    var textField : UITextField?
    var color : UIColor               = UIColor.colorWithHexString("#A2A2A2")
    var redPacketType : RedPacketType = .personal
    var indexPath : IndexPath? {
        didSet {
            textField?.tag = (indexPath?.section)!
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle                     = .none
        self.contentView.backgroundColor        = UIColor.white
        
        // 标题
        titleLabel                              = UILabel()
        titleLabel?.tag                         = 100
        titleLabel?.font                        = CYLayoutConstraintFont(17.0)
        self.contentView.addSubview(titleLabel!)
        titleLabel?.snp.makeConstraints({[weak self] (make) in
            make.centerY.equalTo((self?.contentView)!)
            make.left.equalTo(15.0)
        })
        // 输入框
        textField                               = UITextField()
        textField?.borderStyle                  = .none
        textField?.returnKeyType                = .done
        textField?.delegate                     = self
        textField?.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        textField?.textColor                    = color
        textField?.textAlignment                = .right
        textField?.clearButtonMode              = .always
        self.contentView.addSubview(textField!)
        textField?.snp.makeConstraints({[weak self] (make) in
            make.right.equalTo((self?.contentView.snp.right)!).offset(-CYLayoutConstraintValue(20.0))
            make.centerY.equalTo((self?.contentView)!)
            make.left.equalTo((self?.titleLabel?.snp.right)!).offset(10.0)
        })

    }
    
    /// 输入框内容发送改变
    func textDidChange(_ textField : UITextField) {
        
        let index       = textField.tag
        var text        = textField.text ?? ""
        let length      = text.length 
        var subToIndex  = 0
        switch index {
        case 0:
            subToIndex  = self.redPacketType == .personal ? 9 : 3
            break
        case 1 :
            subToIndex  = self.redPacketType == .personal ? 30 : 9
            break
        case 2 :
            subToIndex  = 30
            break
        default:
            break
        }
        
        if length > subToIndex {
            text            = text.subString(to: subToIndex)
            textField.text  = text
        }
        
        // 是否在输入巴金
        let numberInputTextEnable = ((index == 0 && redPacketType == .personal ) || (index == 1 && redPacketType == .group))
        if (numberInputTextEnable) {
          
            // 判断输入巴金是否大于用户巴金数量
            var coin_quantity           = text.intValue
            // 最大的巴金数 单个红包不能超过20000巴金
            let maxCoin                 = redPacketType == .personal ? 20000 : (20000*100)
            if coin_quantity > maxCoin {
                coin_quantity = maxCoin
            }
            
            if coin_quantity > BK_UserInfo.coin_balance.intValue  {
                coin_quantity           = BK_UserInfo.coin_balance.intValue
            }
            
            text                    = "\(coin_quantity)"

            // 如果输入巴金为0 就禁止输入
            if coin_quantity <= 0 {
                text                    = ""
            }
            
            // 改变发送巴金按钮的选中状态
            textField.text              = text
            let  select                 = text.length > 0
         
            delegate?.coinQuantityTextDidChange?(text, section: index, sendRedPacketSelect: select)
            
        } else {
            
            delegate?.otherTextDidChange?(text, section: index)
            
        }
        

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        NJLog(textField.tag)
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textDidEndEditing?(textField.text!, section: (indexPath?.section)!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


@objc protocol BKSendRedpacketViewControllerDelegate : NSObjectProtocol {
    @objc optional func didSendPacket(_ msg : String, ext :[String :Any]?)
}


/// 发送红包的控制器
class BKSendRedpacketViewController: BKBaseViewController {

    let backButton : BKAdjustButton         = BKAdjustButton(type: .custom)
    let tableView : UITableView             = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth,height : KScreenHeight), style: .grouped)
    var headView : UIView                   = UIView()
    var coinLabel : UILabel                 = UILabel()
    var rechargeButton : UIButton           = UIButton(type: .custom)
    var dataSource : [[[String : String]]]  = [[[String : String]]]()
    var redPacketType : RedPacketType       = .personal
    var footerView : UIView                 = UIView(frame : CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(230.0)))
    let inputCoinLabel                      = UILabel()
    let sendRedPacketButton : UIButton      = UIButton(type: .custom)
    var params : [String :Any]              = [String :Any]()
    var memberCount : Int                   = 1
    weak var delegate : BKSendRedpacketViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setup()
        setupTable()
        loadDatas()
        
        
    }
    
    /// 查看客户巴金详情
    func reqeustCoinbalance() {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getReqeust(baseURLPath + "customers/coin_balance", params: nil, success: {[weak self] (success) in
            HUD.hide(animated: true)
            let return_code = success.value["return_code"]?.intValue ?? 0
            guard return_code == 200 else {
                UnitTools.addLabelInWindow("查看用户巴金失败", vc: self)
                return
            }
            
            let coin_balance : String   = success.value["coin_balance"]?.stringValue ?? "0"
            self?.coinLabel.text        = coin_balance
            
            BKRealmManager.beginWriteTransaction()
            BK_UserInfo.coin_balance    = coin_balance
            BKRealmManager.commitWriteTransaction()
            updateUserInfo(BK_UserInfo)
            
        }) {[weak self] (failure) in
            
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
        }
        
        
    }
    func setup() {
        
        self.view.addSubview(self.tableView)
        self.tableView.backgroundColor = UIColor.RGBColor(243.0, green:243.0, blue: 243.0)
        
    }
    
    func setupTable() {
      
        self.headView.backgroundColor           = UIColor.RGBColor(254.0, green: 110.0, blue: 110.0)
        self.headView.frame                     = CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(303))
        self.tableView.tableHeaderView          = self.headView
        self.tableView.bounces                  = false
        tableView.showsVerticalScrollIndicator  = false
        
        // 返回箭头
        self.headView.addSubview(self.backButton)
        self.backButton.setImage(UIImage(named : "back_white"), for: .normal)
        self.backButton.frame                               = CGRect(x: CYLayoutConstraintValue(14.0), y: CYLayoutConstraintValue(36.0), width: CYLayoutConstraintValue(30.0), height: CYLayoutConstraintValue(23.0))
        self.backButton.setImageViewSizeEqualToCenter(CGSize(width: CYLayoutConstraintValue(15.0), height: CYLayoutConstraintValue(23.0)))
        
        // 标题
        let titleLabel : UILabel                            = UILabel()
        titleLabel.text                                     = "发红包"
        titleLabel.textColor                                = UIColor.white
        titleLabel.font                                     = CYLayoutConstraintFont(17.0)
        self.headView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {[weak self] (make) in
            make.centerY.equalTo((self?.backButton)!)
            make.left.equalTo((self?.backButton.snp.right)!)
        }
        
        self.backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        titleLabel.addTarget(self, action: #selector(back))
       
        // 剩余巴金数量
        let residueCoinLabel                                = UILabel()
        residueCoinLabel.text                               = "剩余巴金"
        residueCoinLabel.textColor                          = UIColor.white
        residueCoinLabel.font                               = CYLayoutConstraintFont(17.0)
        self.headView.addSubview(residueCoinLabel)
        residueCoinLabel.snp.makeConstraints {[weak self] (make) in
            make.left.equalTo((self?.headView.snp.left)!).offset(CYLayoutConstraintValue(20.0))
            make.top.equalTo((self?.headView.snp.top)!).offset(CYLayoutConstraintValue(112.5))
        }
        
        // 图片
        let imageView : UIImageView                 = UIImageView()
        imageView.image                             = UIImage(named: "rechargeCoin")
        self.headView.addSubview(imageView)
        imageView.snp.makeConstraints {[weak self] (make) in
            make.bottom.equalTo((self?.headView.snp.bottom)!).offset(CYLayoutConstraintValue(7.0))
            make.right.equalTo((self?.headView.snp.right)!).offset(-CYLayoutConstraintValue(15.0))
        }
        
        // 巴金数量的 label
        headView.addSubview(coinLabel)
        coinLabel.text                               = BK_UserInfo.coin_balance
        coinLabel.textColor                          = UIColor.white
        coinLabel.font                               = CYLayoutConstraintFont(50.0)
        self.headView.addSubview(coinLabel)
        coinLabel.adjustsFontSizeToFitWidth          = true
        coinLabel.snp.makeConstraints { (make) in
            make.left.equalTo(residueCoinLabel)
            make.top.equalTo(residueCoinLabel.snp.bottom).offset(CYLayoutConstraintValue(5.0))
            make.width.equalTo(CYLayoutConstraintValue(220.0))
        }
        
        // 充值巴金的按钮
        rechargeButton                              = UIButton(type: .custom)
        rechargeButton.backgroundColor              = UIColor.white
        rechargeButton.setTitleColor(UIColor.black, for: .normal)
        rechargeButton.setTitle("充值", for: .normal)
        rechargeButton.titleLabel?.textAlignment    = .center
        rechargeButton.titleLabel?.font             = CYLayoutConstraintFont(17.0)
        rechargeButton.layer.shadowOffset           = CGSize(width:CYLayoutConstraintValue(3.0), height:CYLayoutConstraintValue(3.5));
        rechargeButton.layer.shadowOpacity          = 0.38;
        rechargeButton.layer.shadowColor            = UIColor.black.cgColor
        rechargeButton.addTarget(self, action: #selector(rechargeButtonCoin(_:)), for: .touchUpInside)
        headView.addSubview(rechargeButton)
        rechargeButton.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.coinLabel.snp.bottom)!).offset(CYLayoutConstraintValue(22.0))
            make.left.equalTo(residueCoinLabel)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(125.0), height: CYLayoutConstraintValue(40.0)))
        }
        
        tableView.tableFooterView               = self.footerView
        footerView.backgroundColor              = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        
        // 输入巴金数量
        inputCoinLabel.text                     = "500巴金"
        footerView.addSubview(self.inputCoinLabel)
        inputCoinLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.footerView.snp.top)!).offset(CYLayoutConstraintValue(30.0))
            make.centerX.equalTo((self?.footerView)!)
        }
        
        reloadInputCoinLabel("0")
        
        // 发送红包的按钮
        sendRedPacketButton.setTitle("塞巴金进红包", for: .normal)
        sendRedPacketButton.setTitleColor(UIColor.colorWithHexString("#FFFFFF", alpha: 0.55), for: .normal)
        sendRedPacketButton.setTitleColor(UIColor.white, for: .selected)
        sendRedPacketButton.titleLabel?.font            = CYLayoutConstraintFont(17.0)
        sendRedPacketButton.titleLabel?.textAlignment   = .center
        sendRedPacketButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#FA5959"), forState: .selected)
        sendRedPacketButton.setBackgroundColor(backgroundColor: UIColor.RGBAColor(240.0, green: 139.0, blue: 136.0, alpha: 0.86), forState: .normal)
        sendRedPacketButton.setCornerRadius(CYLayoutConstraintValue(2.5))
        sendRedPacketButton.addTarget(self, action: #selector(sendRedPacketClick(_:)), for: .touchUpInside)
        footerView.addSubview(sendRedPacketButton)
        sendRedPacketButton.isUserInteractionEnabled  = sendRedPacketButton.isSelected
        sendRedPacketButton.snp.makeConstraints {[weak self] (make) in
            make.centerX.equalTo((self?.footerView)!)
            make.top.equalTo((self?.inputCoinLabel.snp.bottom)!).offset(CYLayoutConstraintValue(25.0))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(346.0), height: CYLayoutConstraintValue(50.0)))
        }
        
        // 底部的 label
        let label                               = UILabel()
        label.text                              = "可直接使用收到的巴金发红包"
        label.font                              = CYLayoutConstraintFont(15.0)
        label.textColor                         = UIColor.colorWithHexString("#A2A2A2")
        label.textAlignment                     = .center
        footerView.addSubview(label)
        label.snp.makeConstraints {[weak self] (make) in
            make.centerX.equalTo((self?.footerView)!)
            make.top.equalTo((self?.sendRedPacketButton.snp.bottom)!).offset(CYLayoutConstraintValue(10.0))
        }
        
        
        tableView.delegate                      = self
        tableView.dataSource                    = self
        
        
    }
    
    func loadDatas() {
        
        if  redPacketType                   == .personal {
            
            let sectionOneDict                  = [
                "title" : "总巴金数",
                "placeholder"                 : "填写巴金数额"
            ]
            dataSource.append([sectionOneDict])
            
        } else {
            
            let sectionOneDict                  = [
                "title" : "红包个数",
                "placeholder" : "填写个数"
            ]
            dataSource.append([sectionOneDict])
            
            let sectionTwoDict                  = [
                "title" : "总巴金数",
                "placeholder" : "填写巴金数额"
            ]
            dataSource.append([sectionTwoDict])
            
        }
        
        let sectionLastDict                  = [
            "title" : "留言",
            "placeholder"                   : "爷，给您请安啦！",
            "text"                          : "爷，给您请安啦！"
        ]
        
        dataSource.append([sectionLastDict])
        tableView.reloadData()
        
        
    }
    
    /// 发送红包的按钮点击
    func sendRedPacketClick(_ btn : UIButton) {
        
        
        let quantity            = self.redPacketType == .personal ? 1 : getSectionText(0).intValue
        let coin                = self.redPacketType == .personal ? getSectionText(0).intValue :  getSectionText(1).intValue
        let maxRedpacketCount   = redPacketType == .personal ? 1 : 100
        let message : String    = self.redPacketType == .personal ? getSectionText(1) : getSectionText(2)
        // 判断红包个人是否为0
        guard quantity != 0 else {
            UnitTools.addLabelInWindow("巴金红包个数不能为0", vc:self)
            return
        }
        
        // 巴金红包最多能发100个单个20000的红包
        guard quantity <= maxRedpacketCount else {
            UnitTools.addLabelInWindow("一次最多发100个巴金红包", vc:self)
            return
        }
        
        // 判断单个红包个数是否小于1巴金
        let consult  = (coin / quantity)
        guard consult>=1 else {
            UnitTools.addLabelInWindow("单个巴金红包巴金总数不能小于1巴金", vc:self)
            return
        }
        
        // 请求参数
        params                      = [String :Any]()
        params["quantity"]          = quantity
        params["coin"]              = coin
        params["message"]           = message.isEmpty ? "爷，给您请安啦！" : message
        params["category"]          = redPacketType == .group ? "group_red_packet " : "individual_red_packet"
        
        // 确认的视图
        let prepareView             = BKPreparePacketView()
        prepareView.delegate        = self
        prepareView.data            = params
        prepareView.redPacketType   = self.redPacketType
        let name : String           = self.title ?? "准备发红包"
        prepareView.receiveName     = name
        self.view.addSubview(prepareView)
        prepareView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!)
        }
        
    }
    
    /// 充值巴金功能
    func rechargeButtonCoin(_ btn : UIButton) {
        
        let rechargeViewController          = BKStoreViewController()
        rechargeViewController.title        = "充值巴金"
        rechargeViewController.reqeustURL   = BKApiConfig.KRechargeCoin
        self.navigationController?.pushViewController(rechargeViewController, animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     
        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    func back() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reqeustCoinbalance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    deinit {
        NJLog(self)
    }
    
    
}

extension BKSendRedpacketViewController : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict                                = self.dataSource[indexPath.section][indexPath.row]
        var cell : SendRedPacketCell?            = tableView.dequeueReusableCell(withIdentifier: "RedPacketCell") as? SendRedPacketCell
        if cell == nil {
            cell                                = SendRedPacketCell(style: .default, reuseIdentifier: "RedPacketCell")
            cell?.redPacketType                 = self.redPacketType
            cell?.delegate                      = self
        }
        
        cell?.indexPath                         = indexPath
        cell?.data                              = dict
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(60.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard redPacketType != .group else {
            return 0.01
        }
        guard section != 0 else {
            return 0.01
        }
        return CYLayoutConstraintValue(13.0)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard self.redPacketType != .personal else {
            return 0.01
        }
        guard section != 2 else {
            return 0.01
        }
        return CYLayoutConstraintValue(25.0)
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard self.redPacketType != .personal else {
            return nil
        }
        guard section != 2 else {
            return nil
        }
        
        let view : UIView           = UIView(frame : CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(20.0)))
        view.backgroundColor        = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        let label                   = UILabel(frame: CGRect(x: CYLayoutConstraintValue(15.0), y: CYLayoutConstraintValue(1.25), width: 100.0, height: CYLayoutConstraintValue(20.0)))
        label.text                  = "本群共\(memberCount)人"
        label.textColor             = UIColor.colorWithHexString("#A2A2A2")
        label.font                  = CYLayoutConstraintFont(15.0)
        view.addSubview(label)
        
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard redPacketType != .group else {
            return nil
        }
        
        let view : UIView           = UIView(frame : CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(13.0)))
        view.backgroundColor        = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
    }
    
}

// MARK: - SendRedPacketCellDelegate
extension BKSendRedpacketViewController : SendRedPacketCellDelegate {
    
    func textDidEndEditing(_ text: String, section : Int) {
        reloadSectionSubTitle(at: section, text)
    }
    
    /// 巴金数量输入框
    func coinQuantityTextDidChange(_ text: String, section: Int, sendRedPacketSelect: Bool) {
        
        reloadSectionSubTitle(at: section, text)
        
        let section                     = redPacketType == .personal ? 0 : 1
        let dict                        = self.dataSource[section][0]
        var coin_quantity               = dict["text"] ?? "0"
        if coin_quantity.isEmpty {
            coin_quantity = "0"
        }
        
        reloadInputCoinLabel(coin_quantity)
        
        if (section == 0 && redPacketType == .personal)  {
            reloadSendRedPacketState(sendRedPacketSelect)
        }
        
        if section == 1 && redPacketType == .group {
            reloadSendRedPacketState(sendRedPacketSelect)
        }
   

    }
    /// 其他输入框的输入内容发生改变
    func otherTextDidChange(_ text: String, section: Int) {
        reloadSectionSubTitle(at: section, text)
    }
    
    /// 更新输入框输入内容
    func reloadSectionSubTitle(at section : Int,_ text : String) {
        
        var dict                    = self.dataSource[section][0]
        dict["text"]                = text
        self.dataSource[section]    = [dict]
        
    }
    
    /// 巴金输入大于0时 发送巴金按钮才能选中
    func reloadSendRedPacketState(_ isSelect : Bool) {
        
        sendRedPacketButton.isSelected                  = isSelect
        sendRedPacketButton.isUserInteractionEnabled    = isSelect
        
    }
    
    /// 刷新底部要发送巴金红包数量
    func reloadInputCoinLabel(_ coin_quantity : String) {
       
        let attributedString                    = NSMutableAttributedString(string: coin_quantity, attributes: [NSFontAttributeName : CYLayoutConstraintFont(36.0)])
        attributedString.append(NSAttributedString(string: "巴金", attributes: [NSFontAttributeName : CYLayoutConstraintFont(24.0)]))
        inputCoinLabel.attributedText           = attributedString
        
    }
    
    
}

// MARK: - 准备发送红包的按钮

extension BKSendRedpacketViewController : BKPreparePacketViewDelegate {
    
    /// 发送红包的事件
    func sendPacketButtonClick() {

         HUD.flash(.labeledRotatingImage(image: PKHUDAssets.progressCircularImage, title: nil, subtitle: "准备发送红包"), delay: 30.0)
        
        reqeustSendPacketApi()

    }
    /// 请求发送红包接口,发送红包吧
    func reqeustSendPacketApi() {
        
        
        BKNetworkManager.postReqeust(KURL_SendRedPacket, params: self.params, success: {[weak self] (success) in
            
            HUD.hide(animated: true)
            let return_code     = success.value["return_code"]?.intValue ?? 0
            let return_message = success.value["return_message"]?.stringValue ?? "发送红包失败"
            guard return_code == 201 else {
                UnitTools.addLabelInWindow(return_message, vc: self)
                return
            }
            
            let send_red_packets            = success.value["send_red_packets"]?.dictionaryObject
            let customer                    = success.value["customer"]?.dictionaryObject
            let message : String            = send_red_packets!["message"] as! String
            if send_red_packets == nil || customer == nil {
                self?.delegate?.didSendPacket?(message, ext: nil)
                return
            }
            
            // 发送红包消息的拓展内容
            var ext                         = [String :Any]()
            ext["send_red_packets"]         = send_red_packets!.jsonString
            ext["customer"]                 = customer!.jsonString
            ext["is_money_msg"]             = true
            self?.delegate?.didSendPacket?("[巴金红包] \(message)", ext: ext)
            let _                           = self?.navigationController?.popViewController(animated: true)
            
        }) { (failure) in
            HUD.hide(animated: true)
        }
        
        
    }
    
    func getSectionText(_ section : Int) -> String {
        let dict                    = self.dataSource[section][0]
        let text                    = dict["text"]
        return text ?? ""
    }
    
}

