//
//  BKNotificationsViewControlller.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/24.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

enum RemindMode : String {
    case close = "关闭" // 关闭
    case voice = "声音"// 声音
    case vibrate = "振动"// 振动
    case voiceAndVibrate = "声音和振动" // 声音和振动
}

protocol BKRemindModeViewControllerDelegate : NSObjectProtocol {
     func remindModelSelectModel(_ mode : RemindMode)
}

/// 提醒方式
class BKRemindModeViewController: BKBaseTableViewController {
    var dataArray : [[String : String]] =  [[String : String]]()
    var remindType : RemindMode         = .close
    var isVoiceOpen : Bool              = false
    var isVibrateOpen : Bool            = false
    var switchStatus : [String : Bool]  =  [String : Bool]()
    weak var delegate : BKRemindModeViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataArray                  = [
            ["title" : "声音"],
            ["title" : "振动"],
        ]
        
        let privacyOptions = BKGlobalOptions.curret.privacyOptions
        // 消息提醒方式 震动和声音
        let remindType     = RemindMode(rawValue: privacyOptions.typeString) ?? .voiceAndVibrate
        // 判断用户提醒方式
        switch remindType {
        case .voiceAndVibrate:
            self.isVoiceOpen            = true
            self.isVibrateOpen          = true
            break
        case .voice:
            self.isVoiceOpen            = true
            break
        case .vibrate :
            self.isVibrateOpen          = true
            break
        default:
            break
        }
        
        self.switchStatus["0"]          = isVoiceOpen
        
        self.switchStatus["1"]          = isVibrateOpen
        
        self.tableView.reloadData()
  
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell                                = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell                                = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
            cell?.selectionStyle                = .none
            cell?.textLabel?.font               = CYLayoutConstraintFont(16.0)
            
        }
        
        cell?.textLabel?.text                   = self.dataArray[indexPath.row]["title"]
        cell?.detailTextLabel?.text             = self.dataArray[indexPath.row]["subTitle"]
        
        if (indexPath.row != 2) {
            // 开关switch
            let switchView                      = UISwitch()
            let isOn                            = self.switchStatus["\(indexPath.row)"] ?? false
            switchView.setOn(isOn, animated: false)

            switchView.tag                      = indexPath.row
            switchView.onTintColor              = UIColor.colorWithHexString("#FAB66F")
            cell?.accessoryView                 = switchView
            switchView.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
            
            
        }
        return cell!
    }
    
    /// 点击了开关
    @objc func changeValue(_ switchView : UISwitch) {
        self.switchStatus["\(switchView.tag)"] = switchView.isOn
        
        let switchOneOpen   = self.switchStatus["0"] ?? false
        let swicthTwoOpen   = self.switchStatus["1"] ?? false
        
        if switchOneOpen && swicthTwoOpen { // 同时打开 声音和振动
            self.remindType = .voiceAndVibrate
        } else if (switchOneOpen && !swicthTwoOpen) { // 只打开声音
            self.remindType = .voice
        } else if (!switchOneOpen && swicthTwoOpen) { // 只打开振动
            self.remindType = .vibrate
        } else { // 振动和声音都没有打开
            self.remindType = .close
        }
        self.delegate?.remindModelSelectModel(self.remindType)
        
    }

    
}

/// 消息提醒
class BKNotificationsViewControlller: BKBaseTableViewController , BKRemindModeViewControllerDelegate {
    var dataArray : [[[String : String]]] =  [[[String : String]]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
    }
    func setup() {
        
        self.title                          = "消息提醒"
        let globalOptions                   = BKGlobalOptions.curret
        let privacyOptions                  = globalOptions.privacyOptions
        self.dataArray                      = [
            [["title" : "接受新消息通知","subTitle" : globalOptions.supportUserNotifications ? "已开启" : "已关闭"]],
            [["title" : "提醒方式" , "subTitle" :privacyOptions.typeString]]
        ]
        
        self.tableView.reloadData()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell                                = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell                                = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
            cell?.selectionStyle                = .none
            cell?.textLabel?.font               = CYLayoutConstraintFont(16.0)
            cell?.detailTextLabel?.font         = CYLayoutConstraintFont(14.0)
            cell?.detailTextLabel?.textColor    = UIColor.colorWithHexString("#898989")
        }
        
        cell?.textLabel?.text                   = self.dataArray[indexPath.section][indexPath.row]["title"]
        cell?.detailTextLabel?.text             = self.dataArray[indexPath.section][indexPath.row]["subTitle"]
        cell?.accessoryType                     = indexPath.section == 0 ? .none : .disclosureIndicator
        
        
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let remindModeViewController            = BKRemindModeViewController()
            remindModeViewController.delegate       = self
            self.navigationController?.pushViewController(remindModeViewController, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CYLayoutConstraintValue(15.0) : 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return CYLayoutConstraintValue(44.0)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var tableFootView                               = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FooterView")
        if tableFootView == nil {
            
            tableFootView                               = UITableViewHeaderFooterView(reuseIdentifier:"FooterView")
            tableFootView?.contentView.backgroundColor      = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        }
        
        tableFootView?.contentView.removeAllSubviews()
        
        let label                                       = UILabel()
        label.tag                                       = 100
        label.frame                                     = CGRect(x: 15.0, y: 0.0, width: KScreenWidth - 30.0, height: section == 0 ? CYLayoutConstraintValue(44.0) : CYLayoutConstraintValue(30.0))
        label.font                                      = CYLayoutConstraintFont(14.0)
        label.textColor                                 = UIColor.colorWithHexString("#898989")
        label.text                                      = section == 0 ? "如果你要关闭或开启巴爷汇的新消息通知，请在Iphone 的“设置”-“通知”功能中,找到应用程序 “巴爷汇” 更改" : "当巴爷汇运行时，你可以设置是否需要声音或振动"
        label.numberOfLines                             = 0
        tableFootView?.contentView.addSubview(label)

        return tableFootView!
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view                                        = UIView()
        view.frame                                      = CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(15.0))
        view.backgroundColor = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        return UIView()
    }
    
    /// 选了提醒方式
    func remindModelSelectModel(_ mode: RemindMode) {
        
        var dict                                        = self.dataArray[1][0]
        dict["subTitle"]                                = mode.rawValue
        self.dataArray[1][0]                            = dict
        self.tableView.reloadData()
        
        BKRealmManager.beginWriteTransaction()
        
        BKGlobalOptions.curret.privacyOptions.remindType = mode
        
        BKRealmManager.commitWriteTransaction()
        
        
    }

    
}
