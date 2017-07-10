//
//  BKScanQRCodeViewController.swift
//  BKQRCodeDemo
//
//  Created by 董招兵 on 2016/11/19.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import AVFoundation

class BKScanQRCodeViewController: UIViewController {
    var session: AVCaptureSession?

    @IBOutlet weak var scanBackgroupdView: UIImageView! {
        didSet {
            scanBackgroupdView.image = UIImage(named: "BKScanQRCode.bundle/scanscanBg")
        }
    }
    @IBOutlet weak var lineViewTop: NSLayoutConstraint!
    @IBOutlet weak var lineView: UIImageView! {
        didSet {
            lineView.image = UIImage(named: "BKScanQRCode.bundle/scanLine")
        }
    }
    var waitingView : UIView?
    var maskLayer : CAShapeLayer?
    var shadowLayer : CAShapeLayer?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title                      = "扫一扫"
        self.setup()
    }
    
    func setup() {
        
        self.waitingView = UIView(frame:CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        self.waitingView?.backgroundColor = UIColor.black
        self.view.addSubview(self.waitingView!)
        
        
        let waitLabel               = UILabel()
        waitLabel.textColor         = UIColor.white
        waitLabel.textAlignment     = .center
        let labelY                  = ((self.waitingView?.frame.size.height)! - 20.0 ) * 0.5
        let labelX                  = ((self.waitingView?.frame.size.width)! - 100.0) * 0.5
        waitLabel.frame             = CGRect(x: labelX, y: labelY, width: 100.0, height: 20.0)
        waitLabel.text              = "正在加载..."
        self.waitingView?.addSubview(waitLabel)
        
        let activityView            = UIActivityIndicatorView()
        activityView.activityIndicatorViewStyle = .whiteLarge
        
        let activityViewY                  = labelY - 60.0
        let activityViewX                  = ((self.waitingView?.frame.size.width)! - 40.0) * 0.5
        activityView.frame          = CGRect(x: activityViewX, y: activityViewY, width: 40.0, height: 40.0)
        activityView.startAnimating()
        self.waitingView?.addSubview(activityView)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.waitingView?.removeFromSuperview()
        startAnimation()
        self.startScan()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session?.stopRunning()
        self.lineView.layer.removeAllAnimations()
        
    }
    
    func startScan() -> () {
        
        guard session == nil else {
            session?.startRunning()
            return
        }
        // 1. 设置输入
        // 1.1 获取摄像头设备
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // 1.2 把摄像头设备当做输入设备
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
        }catch {
            print(error)
            return
        }
        
        
        
        // 2. 设置输出
        let output = AVCaptureMetadataOutput()
        // 2.1 设置结果处理的代理
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        
        
        // 3. 创建会话, 连接输入和输出
        session = AVCaptureSession()
        if session!.canAddInput(input) && session!.canAddOutput(output) {
            session!.addInput(input)
            session!.addOutput(output)
        }else {
            return
        }
        
        // 3.1 设置二维码可以识别的码制
        // 设置识别的类型, 必须要在输出添加到会话之后, 才可以设置, 不然, 崩溃
        // output.availableMetadataObjectTypes
        // AVMetadataObjectTypeQRCode
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        output.rectOfInterest      = CGRect(x:0.35, y:0.3, width:0.65, height: 0.7)
        
        // 3.2 添加视频预览图层(让用户可以看到界面) (不是必须添加的)
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer?.frame = view.layer.bounds
        //        view.layer.addSublayer(layer)
        view.layer.insertSublayer(layer!, at: 0)
        
        
        
        // 4. 启动会话, (让输入开始采集数据, 输出对象,开始处理数据)
        session!.startRunning()
        
        
    }
    


    
    @IBOutlet weak var scanBackView: UIView!
    func startAnimation() {
        
        lineViewTop.constant = -scanBackView.frame.size.height
        view.layoutIfNeeded()
        
        lineViewTop.constant = scanBackView.frame.size.height
        
        UIView.animate(withDuration: 1) {
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.view.layoutIfNeeded()
        }
    }

    

}

extension BKScanQRCodeViewController :  AVCaptureMetadataOutputObjectsDelegate {
    // 扫描到结果之后调用
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        guard metadataObjects.count != 0 else {
            return
        }
        
        let result = metadataObjects.last as! AVMetadataMachineReadableCodeObject
        let msg    = result.stringValue
        guard msg != nil else {
            UnitTools.addLabelInWindow("不能被识别的二维码", vc: self)
            return
        }
         // 扫描到用户名片
        if (msg?.contains("bayefriend"))! {
        
            let userDetailViewController            = BKUserDetailViewController()
            userDetailViewController.userId         = (msg?.components(separatedBy: ":").last)!
            self.navigationController?.pushViewController(userDetailViewController, animated: true)
        }
        
    }
    
}

