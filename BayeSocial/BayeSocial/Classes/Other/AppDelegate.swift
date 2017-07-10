                                                                                                                                                                                                 
import UIKit
import IQKeyboardManagerSwift

let AppID                      = "wxc9587e307525b637"
let APP_SECRET                 = "6662f3c75ca7d9f43ce4411dbedbc049"
 
// 正式账号
let EaseMobAppKey : String     = "bayetech#landlord"
 
 /**
  自定义 LOG
  */
func NJLog<T>(_ message: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
    if BKApiConfig.isDebugMode() {
        print("\n\(methodName) \n \(message)\n")
    }
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,WXApiDelegate {
    
    var window: UIWindow?
    var displayImageView : UIImageView?
    lazy var certName : String =  {
        var cerName = ""
        if BKApiConfig.isDebugMode() {
            cerName     = "bayeStyle_dev";
        } else {
            cerName     = "BayeStyle_Production";
        }
        return cerName
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        window                                             = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor                            = UIColor.white
        window?.makeKeyAndVisible()
              
        // 配置 Realm 数据库
        BKRealmManager.realmConfiguration()
        
        IQKeyboardManager.sharedManager().enable                = true

        // 初始化环信 SDK 的配置
        initializeEaseMobSDKWithOptions(application, launchOptions: launchOptions)
      
        initShareSDK()
        
        // 是否加载版本新特性页面
        guard !needShowLoadingPage() else {
            addLoadingPageViewControlller()
            return true
        }

        // 是否免登陆
        if !userDidLogin {
            displayMainViewController()
            self.addDisplayImageView()
        } else {
            displayLoginViewController()
        }

        if KURL_Customer_friends.contains("api-staging") {
            UnitTools.addLabelInWindow("内网环境", vc: nil)
        }
        
        /// 收集异常错误信息
        BKExceptions.startCollectionCrashLogs()
        
        
        return true
    }
    
    /// 加载版本新特性页面
    func addLoadingPageViewControlller() {
        
        let loadPageViewController                  = BKLoadingPageViewController()
        loadPageViewController.view.backgroundColor = UIColor.RandomColor()
        self.window?.rootViewController             = loadPageViewController
        
    }
    
    /// 是否显示版本新特性页面
    func needShowLoadingPage() -> Bool {
        
        let currentVersion      = UnitTools.appCurrentVersion()
        let lastVersion         = UserDefaults.standard.object(forKey: "LoadPage")
        guard lastVersion != nil else {
            UserDefaults.standard.set(currentVersion, forKey: "LoadPage")
            return true
        }
        
        return false

    }
    
    /// 添加一个延时加载启动页的图片
    func addDisplayImageView() {
        
        let image = UIImage.getLauch()
        guard image != nil else {
            return
        }
        
        self.displayImageView                           = UIImageView()
        self.displayImageView?.isUserInteractionEnabled = true
        self.displayImageView?.image                    = image
        self.displayImageView?.frame                    = (self.window?.bounds)!
        self.window?.addSubview(self.displayImageView!)
        self.perform(#selector(disMissDefultViewController), with: nil, afterDelay: 10.0)
        
    }
    
    /// 移除默认的视图
    func disMissDefultViewController() {
        
        guard self.displayImageView != nil else {
            return
        }

        weak var weakSelf       = self
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
            weakSelf?.displayImageView?.alpha = 0.0
            weakSelf?.displayImageView?.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.2, 1.2, 1.0)
            }) { (finished) in
                weakSelf?.displayImageView?.removeFromSuperview()
                weakSelf?.displayImageView = nil
        }
        
    }
    /// 初始化 ShareSDK
    func initShareSDK() {

         let wechatPlatform = SSDKPlatformType.typeWechat.rawValue
         let platforms  = [NSNumber(value: wechatPlatform)]
        ShareSDK.registerActivePlatforms(platforms, onImport: { (platform) in
            switch platform {
            case  .typeWechat:
                ShareSDKConnector.connectWeChat(WXApi.self)
                break
            default :
                break
            }

        }) { (platform, appInfo) in
            switch platform {
            case SSDKPlatformType.typeWechat:
                appInfo?.ssdkSetupWeChat(byAppId: AppID, appSecret: APP_SECRET)
                break
            default :
                break
            }
        }


   }
    
    /// 主页面
    func displayMainViewController() {
        let tabBarController            = BKTabBarViewController()
        window?.rootViewController      = tabBarController
    }
    
    /// 登录页面
    func displayLoginViewController() {
     
        let loginViewController                                 = BKLoginViewController()
        let nav                                                 = BKNavigaitonController(rootViewController : loginViewController)
        window?.rootViewController                              = nav

    }
    

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    ///MARK://处理
    /// iOS10之前 处理从别的 app 返回到该应用后的一些回调
    fileprivate func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return  paymentResutlWithURL(url)
    }
    /// iOS10 处理从别的 app 返回到该应用后的一些回调
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool  {
        return  paymentResutlWithURL(url)
    }
    
    /// 处理从微信支付宝返回到巴爷供销社后支付结果
    func paymentResutlWithURL(_ url : URL) -> Bool {
        return BKPaymentManager.shared.handelOpenURL(url)
    }
    
}


extension AppDelegate {
    var rootViewControlller : UIViewController {
        get {
            return (AppDelegate.appDelegate().window?.rootViewController)!
        }
    }
    class func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

