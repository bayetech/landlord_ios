//
//  BKRedPacketDetailsViewController.swift
//  BayeSocial
//
//  Created by dzb on 2016/12/30.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import HandyJSON
import PKHUD

/// 红包详情页类型
@objc enum PacketDetailsType  : Int {
    case didSeparate = 0
    case noSeparate
}

/// 红包详情的控制器
class BKRedPacketDetailsViewController: BKBaseViewController {

    var navView     : BKNavigaitonBar       = BKNavigaitonBar.shared()
    var redPacketId : String?
    var message : String?
    var tableView   : UITableView           = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: KScreenHeight), style: .grouped)
    var backGroupdView : UIView             = UIView()
    var headView : UIView                   = UIView()
    var detailsType : PacketDetailsType     = .noSeparate
    var backgroundViewHeight   : CGFloat    = 0.0
    var avatarImageView : UIImageView       = UIImageView()
    var nameLabel : UILabel                 = UILabel()
    var textLabel : UILabel                 = UILabel()
    var coinLabel : UILabel?
    var redPacketDetail : BKRedPacketDetailModel?
    var redPacketDidOpen : Bool = false
    var redPacketType : RedPacketType = .group
    var isOpenAll : Bool = false
    var redPacketOwner : Bool               = false
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNav()
        setupHeadView()
        requestRedPacketDetail()
        
    }
    
    func setupNav() {
        
        self.view.addSubview(navView)
        navView.navTitle        = "红包详情"
        navView.backgroundColor = UIColor.colorWithHexString("#FE6E6E")
        navView.backAction      = ({[weak self] (navBar) in
            self?.popToBack()
        })
        
    }
    
    /// 查看红包详情
    func requestRedPacketDetail() {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getReqeust(KURL_SendRedPacket + "/\(redPacketId!)", params:nil, success: { [weak self] (success) in
            HUD.hide(animated: true)
            let return_code = success.value["return_code"]?.intValue ?? 0
            let return_message = success.value["return_message"]?.stringValue ?? "查看失败"
            guard return_code == 200 else {
                UnitTools.addLabelInWindow(return_message, vc: self)
                return
            }
            
            let send_red_packets            = success.value["send_red_packets"]?.dictionaryObject
            self?.redPacketDetail           = JSONDeserializer<BKRedPacketDetailModel>.deserializeFromDictionary(send_red_packets)
            // 更新 UI
            self?.update()
            
        }) {[weak self]  (failure) in
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
        }
        
    }
    
    func update() {
        
        self.redPacketDidOpen           = (self.redPacketDetail != nil && (self.redPacketDetail?.red_packets?.count)! != 0 )
        self.tableView.separatorStyle   = (self.redPacketDidOpen) ? .singleLine : .none
        // 设置发红包的人资料和我抢到红包的金额
        self.nameLabel.text             = self.redPacketDetail?.owner_customer_name
        self.avatarImageView.kf.setImage(with: URL(string : (self.redPacketDetail?.owner_customer_avatar)!), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        self.textLabel.text             = self.redPacketDetail?.message
        self.redPacketType              = self.redPacketDetail?.category == "group_red_packet" ? .group : .personal
        // 判断红包领取数量和总数量 绝对是否领取完毕
        self.isOpenAll                  = (self.redPacketDetail?.opened_red_packets_count == self.redPacketDetail?.red_packets_count)
        // 判断自己是否是红包的发送者
        self.redPacketOwner             = (self.redPacketDetail?.owner_customer_uid == easemob_username)
        
        self.tableView.reloadData()
        
        // 查看自己领的红包数量
        if self.redPacketDidOpen {
        
            for subject in (self.redPacketDetail?.red_packets)! {
                let customer_uid = subject.customer_uid
                if customer_uid == easemob_username {
                    setupCoin_balance(subject.coin)
                    break
                }
            }
            
        }
        
        
    }
    
    
    func setupHeadView() {
        
        tableView.delegate                              = self
        tableView.dataSource                            = self
        backgroundViewHeight                            = detailsType == .noSeparate ? CYLayoutConstraintValue(123.0) : CYLayoutConstraintValue(213.0)
        tableView.separatorStyle                        = .none
        tableView.tableFooterView                       = UIView()
        let headViewHeight                              = detailsType == .noSeparate ? CYLayoutConstraintValue(221.5) : CYLayoutConstraintValue(311.5)
        view.insertSubview(tableView, belowSubview: navView)

        let headViewTop                                 = 1200 - headViewHeight
        headView                                        = UIView(frame: CGRect(x: 0.0, y: 0, width: KScreenWidth, height: 1200.0))
        headView.backgroundColor                        = UIColor.colorWithHexString("#FE6E6E")
        tableView.tableHeaderView                       = headView
        tableView.contentInset                          = UIEdgeInsets(top:-headViewTop, left: 0.0, bottom: 0.0, right: 0.0)
    
        headView.addSubview(backGroupdView)
        backGroupdView.backgroundColor = UIColor.white
        backGroupdView.snp.makeConstraints {[weak self] (make) in
            make.bottom.equalTo((self?.headView)!)
            make.left.equalTo((self?.headView)!)
            make.size.equalTo(CGSize(width: KScreenWidth, height:(self?.backgroundViewHeight)!))
        }
    
        let imageView : UIImageView                     = UIImageView()
        imageView.image = UIImage(named: "redpacket_details_top")
        backGroupdView.addSubview(imageView)
        imageView.snp.makeConstraints {[weak self] (make) in
            make.top.left.right.equalTo((self?.backGroupdView)!)
        }
        
        // 头像
        avatarImageView.image                           = KCustomerUserHeadImage
        avatarImageView.setCornerRadius(CYLayoutConstraintValue(27.5))
        headView.addSubview(avatarImageView)
        
        avatarImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageView)
            make.centerY.equalTo(imageView).offset(CYLayoutConstraintValue(10.5))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(55.0), height: CYLayoutConstraintValue(55.0)))
        }
        
        
        // 昵称
        headView.addSubview(nameLabel)
        nameLabel.font          = CYLayoutConstraintFont(15.0)
        nameLabel.textAlignment = .center
        nameLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.avatarImageView.snp.bottom)!).offset(CYLayoutConstraintValue(8.0))
            make.left.right.equalTo((self?.headView)!)
        }
        
        // 红包祝福语内容
        headView.addSubview(textLabel)
        textLabel.font          = CYLayoutConstraintFont(14.0)
        textLabel.textColor     = UIColor.colorWithHexString("#94928D")
        textLabel.textAlignment = .center
        textLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.nameLabel.snp.bottom)!).offset(CYLayoutConstraintValue(5.0))
            make.left.right.equalTo((self?.headView)!)
        }
        
        // 我抢过的红包显示抢到的巴金金额和提现按钮
        if detailsType          == .didSeparate {
            
            coinLabel                               = UILabel()
            headView.addSubview(coinLabel!)
            coinLabel?.textAlignment                = .center
            coinLabel?.snp.makeConstraints {[weak self] (make) in
                make.top.equalTo((self?.textLabel.snp.bottom)!).offset(CYLayoutConstraintValue(20.0))
                make.left.right.equalTo((self?.headView)!)
            }
            
            // 零钱提现的按钮
            let button : UIButton                   = UIButton(type: .custom)
            button.setTitle("已存入我的巴金，可用于发红包", for: .normal)
            button.setTitleColor(UIColor.colorWithHexString("#7290D3"), for: .normal)
            button.titleLabel?.textAlignment        = .center
            button.titleLabel?.font                 = CYLayoutConstraintFont(12.0)
            headView.addSubview(button)
            button.snp.makeConstraints({[weak self] (make) in
                make.top.equalTo((self?.coinLabel?.snp.bottom)!).offset(-CYLayoutConstraintValue(3.0))
                make.centerX.equalTo((self?.headView)!)
            })
            
            // 设置抢到巴金默认值为1.0
            setupCoin_balance(0.0)
            
        }
        
        
        
    }

    func setupCoin_balance(_ coin : Double) {
        
        let attributedString                    = NSMutableAttributedString(string: "\(coin)", attributes: [NSFontAttributeName : CYLayoutConstraintFont(50.0)])
        attributedString.append(NSAttributedString(string: "巴金", attributes: [NSFontAttributeName : CYLayoutConstraintFont(15.0)]))
        coinLabel?.attributedText               = attributedString
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    deinit {
        NJLog(self)
    }
    
    
}


// MARK: - UITableViewDelegate , UITableViewDataSource
extension BKRedPacketDetailsViewController : UITableViewDelegate,UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.redPacketDidOpen {
            return (self.redPacketDetail?.red_packets?.count)!
        } else {
            return 4
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        if redPacketDidOpen {
            
            var cell        = tableView.dequeueReusableCell(withIdentifier: "Cell")
            
            if cell == nil {
                
                cell                    = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell?.selectionStyle    = .none
                
                // 用户头像
                let avatarImageView     = UIImageView()
                avatarImageView.setCornerRadius(CYLayoutConstraintValue(20.0))
                avatarImageView.tag     = 100
                avatarImageView.image   = KCustomerUserHeadImage
                cell?.contentView.addSubview(avatarImageView)
                avatarImageView.snp.makeConstraints({ (make) in
                    make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(18.0))
                    make.centerY.equalTo((cell?.contentView)!)
                    make.size.equalTo(CGSize(width: CYLayoutConstraintValue(40.0), height: CYLayoutConstraintValue(40.0)))
                })
                
                // 用户昵称
                let nameLabel           = UILabel()
                nameLabel.font          = CYLayoutConstraintFont(15.0)
                nameLabel.tag           = 200
                cell?.contentView.addSubview(nameLabel)
                nameLabel.snp.makeConstraints({ (make) in
                    make.top.equalTo((cell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(16.0))
                    make.left.equalTo(avatarImageView.snp.right).offset(CYLayoutConstraintValue(14.0))
                    make.width.equalTo(CYLayoutConstraintValue(100.0))
                })
                
                // 时间
                let titleLabel         = UILabel()
                titleLabel.textColor   = UIColor.colorWithHexString("#94928D")
                titleLabel.font        = CYLayoutConstraintFont(15.0)
                titleLabel.tag         = 300
                cell?.contentView.addSubview(titleLabel)
                titleLabel.snp.makeConstraints({ (make) in
                    make.top.equalTo((nameLabel.snp.bottom)).offset(CYLayoutConstraintValue(5.0))
                    make.left.right.equalTo(nameLabel)
                })
                
                // 巴金数额
                let coinLabel               = UILabel()
                coinLabel.textAlignment     = .right
                coinLabel.font              = CYLayoutConstraintFont(15.0)
                coinLabel.tag               = 400
                cell?.contentView.addSubview(coinLabel)
                coinLabel.snp.makeConstraints({ (make) in
                    make.top.equalTo(nameLabel)
                    make.right.equalTo((cell?.contentView.snp.right)!).offset(-CYLayoutConstraintValue(16.5))
                    make.width.equalTo(CYLayoutConstraintValue(180.0))
                })
                
                // 最佳手气
                let betterImageView         = UIImageView()
                betterImageView.image       = UIImage(named: "better_luck")
                betterImageView.tag         = 500
                cell?.contentView.addSubview(betterImageView)
                betterImageView.snp.makeConstraints({ (make) in
                    make.top.equalTo(titleLabel.snp.top).offset(CYLayoutConstraintValue(2.0))
                    make.right.equalTo(coinLabel)
                })
                
                
            }
            
            let redPacketSubject            = (redPacketDetail?.red_packets?[indexPath.row])!
            
            let avatarImageView             = cell?.contentView.viewWithTag(100) as! UIImageView
            avatarImageView.kf.setImage(with: URL(string:redPacketSubject.customer_avatar), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
            
            let nameLabel                   = cell?.contentView.viewWithTag(200) as! UILabel
            nameLabel.text                  = redPacketSubject.customer_name
            
            let titleLabel                  = cell?.contentView.viewWithTag(300) as! UILabel
            titleLabel.text                 = Date.dateFormatterTimeInterval(redPacketSubject.opened_at, tiemFormatter: "HH:mm:ss")
            
            let coinLabel                   = cell?.contentView.viewWithTag(400) as! UILabel
            coinLabel.text                  = "\(redPacketSubject.coin)巴金"
            
            let betterImageView             = cell?.contentView.viewWithTag(500) as! UIImageView
            
            if self.isOpenAll {
                // 判断最佳手气
                betterImageView.isHidden        = !(self.redPacketDetail?.max_coin_customer_uid == redPacketSubject.customer_uid)
            } else {
                betterImageView.isHidden        = true
            }
            
            return cell!
            
        } else  {
            
            // 没有数据的占位 cell
            var cell                                = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
            if cell == nil {
                cell                                = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
                cell?.selectionStyle                = .none
                cell?.backgroundColor               = UIColor.clear
                cell?.contentView.backgroundColor   = UIColor.clear
            }
            
            return cell!
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(70.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.redPacketDetail != nil else {
            return 0.01
        }

        return CYLayoutConstraintValue(27.5)

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard self.redPacketDetail != nil else {
            return nil
        }
        
        var headView    = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeadView")
        if headView == nil {
            
            headView                                = UITableViewHeaderFooterView(reuseIdentifier: "HeadView")
            headView?.contentView.backgroundColor   = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
            
            let titleLabel                          = UILabel()
            titleLabel.textColor                    = UIColor.colorWithHexString("#94928D")
            titleLabel.font                         = UIFont.systemFont(ofSize: 13.0)
            titleLabel.tag                          = 100
            headView?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints({ (make) in
                make.edges.equalTo((headView?.contentView)!).inset(UIEdgeInsetsMake(0.0, CYLayoutConstraintValue(17.5), 0.0, 0.0))
            })
            
        }
        
        let label   :  UILabel          = headView?.contentView.viewWithTag(100) as! UILabel
        
        // 个人红包
        if self.redPacketType == .personal {
            
            label.text                      = isOpenAll ? String(format: "1个红包共%.1f巴金",(self.redPacketDetail?.coin)!) : ((self.redPacketDetail?.expired_at)! ? String(format: "该该红包已过期。已领取%d/%d个, 共%.1f/%.1f巴金",(self.redPacketDetail?.opened_red_packets_count)!,(self.redPacketDetail?.red_packets_count)!,(self.redPacketDetail?.opened_coin)!,(self.redPacketDetail?.coin)!) : String(format: "红包巴金总数%.1f巴金,等待对方领取",(self.redPacketDetail?.coin)!))

        } else { // 群组红包
            
            if self.redPacketOwner && !isOpenAll {
                
                // 自己的红包没有被领完 显示领取进度和剩余巴金
                label.text                      = String(format: "%@已领取%d/%d个, 共%.1f/%.1f巴金",((self.redPacketDetail?.expired_at)! ? "该红包已过期。" : ""),(self.redPacketDetail?.opened_red_packets_count)!,(self.redPacketDetail?.red_packets_count)!,(self.redPacketDetail?.opened_coin)!,(self.redPacketDetail?.coin)!)
                
            } else if self.redPacketOwner && isOpenAll {
                
                // 自己的红包被全部领完显示 领完的时间
                let time                        = (self.redPacketDetail?.last_opened_at)! - (self.redPacketDetail?.created_at)!
                let openAllTime                 = Date.stringWithCurrentTimeInterval(Int(time))
                label.text                      = String(format: "%d个红包共%.1f巴金, %@被抢完",(self.redPacketDetail?.red_packets_count)!,(self.redPacketDetail?.coin)!,openAllTime)
                
            } else if !self.redPacketOwner {
                
                // 别人的红包支持查看领取进度
                label.text                      = String(format: "%@领取%d/%d个",((self.redPacketDetail?.expired_at)! ? "该红包已过期。" : ""),(self.redPacketDetail?.opened_red_packets_count)!,(self.redPacketDetail?.red_packets_count)!)
                
            }
            
        }
        
        
        return headView
    }
    

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard self.redPacketDetail != nil else {
            return 0.01
        }
        return CYLayoutConstraintValue(135.0)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard self.redPacketDetail != nil else {
            return nil
        }
        
        var footView    = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FootView")
        if footView == nil {
            
            footView                                    = UITableViewHeaderFooterView(reuseIdentifier: "FootView")
            
            // 查看我的红包记录
            let mineRedPacketsBtn                       = UIButton(type: .custom)
            mineRedPacketsBtn.setTitle("查看我的红包纪录", for: .normal)
            mineRedPacketsBtn.setTitleColor(UIColor.colorWithHexString("#7290D3"), for: .normal)
            mineRedPacketsBtn.titleLabel?.font          = CYLayoutConstraintFont(13.0)
            mineRedPacketsBtn.tag                       = 200
            mineRedPacketsBtn.addTarget(self, action: #selector(mineRedPacketsBtnClick), for: .touchUpInside)
            mineRedPacketsBtn.titleLabel?.textAlignment = .center
            footView?.contentView.addSubview(mineRedPacketsBtn)
            mineRedPacketsBtn.snp.makeConstraints({ (make) in
                make.top.equalTo((footView?.snp.top)!).offset(CYLayoutConstraintValue(40.0))
                make.centerX.equalTo(footView!)
            })
            
            let titleLabel                              = UILabel()
            titleLabel.textColor                        = UIColor.colorWithHexString("#94928D")
            titleLabel.font                             = UIFont.systemFont(ofSize: 13.5)
            titleLabel.tag                              = 100
            footView?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(mineRedPacketsBtn.snp.bottom).offset(CYLayoutConstraintValue(20.0))
                make.centerX.equalTo(footView!)
            })
            
        }
        
        let label   :  UILabel          = footView?.contentView.viewWithTag(100) as! UILabel
        let button : UIButton           = footView?.contentView.viewWithTag(200) as! UIButton

        if !self.redPacketDidOpen && self.redPacketOwner {
            label.text                  = "未领取的红包，将于24小时后发起退款"
        } else if self.redPacketDidOpen && self.redPacketOwner {
            label.text                  = "收到的巴金可直接用来发红包"
        } else if self.detailsType == .didSeparate {
            label.text                  = "收到的巴金可直接用来发红包"
        }
        

        button.isHidden                 = true
        
        return footView
        
    }
    
    /// 查看我的红包记录
    func mineRedPacketsBtnClick() {
        
        
        
    }
}
