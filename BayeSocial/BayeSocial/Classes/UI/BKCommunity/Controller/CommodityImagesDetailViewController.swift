//
//  CommodityImagesDetailViewController.swift
//  Baye
//
//  Created by 孙磊 on 15/9/6.
//  Copyright (c) 2015年 Bayekeji. All rights reserved.
//

import UIKit
import Kingfisher

class CommodityImagesDetailViewController: UIViewController,UIScrollViewDelegate {
   
    
    var commodityImageArray = [String]()
    var currentPage:Int = 0
    var commodityImageScrollView:UIScrollView!
    var commodityImagePageControl:UIPageControl! = UIPageControl()
    var imageView = UIImageView()
    var fromImage:UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
    }

    func initialUI() {
        
        if self.commodityImageScrollView == nil {
            
            self.commodityImageScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
            self.commodityImageScrollView.contentSize = CGSize(width: KScreenWidth*CGFloat(commodityImageArray.count),height: KScreenHeight)
//            self.commodityImageScrollView.minimumZoomScale = 0.2
//            self.commodityImageScrollView.maximumZoomScale = 5.0
            self.commodityImageScrollView.backgroundColor = UIColor.clear
            self.commodityImageScrollView.isPagingEnabled = true
            self.commodityImageScrollView.delegate = self;
            self.commodityImageScrollView.showsHorizontalScrollIndicator = false
            self.view.addSubview(self.commodityImageScrollView)
            if fromImage != nil {
                
                self.commodityImageScrollView.contentSize       = CGSize(width: KScreenWidth,height: 0)
                let imageView:UIImageView                   = UIImageView()
                imageView.center                                = CGPoint(x: self.view.center.x , y: self.view.center.y)
                imageView.bounds                                = CGRect(x: 0,y: 0, width: KScreenWidth, height: fromImage!.size.height * KScreenWidth / fromImage!.size.width)
                imageView.image                                 = fromImage
                self.commodityImageScrollView.addSubview(imageView)
                imageView.isUserInteractionEnabled                = true
                let singleTapGestureRecognizer                  = UITapGestureRecognizer(target: self, action: #selector(CommodityImagesDetailViewController.singleTapGestureRecognizer(_:)))
                singleTapGestureRecognizer.numberOfTapsRequired = 1
                let doubleTapGestureRecognizer                  = UITapGestureRecognizer(target: self, action: #selector(CommodityImagesDetailViewController.doubleTapGestureRecognizer(_:)))
                doubleTapGestureRecognizer.numberOfTapsRequired = 2
                let longpressGesutre                            = UILongPressGestureRecognizer(target: self, action: #selector(CommodityImagesDetailViewController.handleLongpressGesture(_:)))
                imageView.tag                                   = 230
                imageView.addGestureRecognizer(singleTapGestureRecognizer)
                imageView.addGestureRecognizer(longpressGesutre)
                
            } else {
                
                for i in 0 ..< commodityImageArray.count {
                    
                    let scrollView                                       = UIScrollView()
                    scrollView.delegate                                  = self
                    scrollView.maximumZoomScale                          = 3.0
                    scrollView.minimumZoomScale                          = 1.0
                    scrollView.isScrollEnabled                             = true
                    scrollView.bounces                                   = false
                    scrollView.translatesAutoresizingMaskIntoConstraints = false
                    scrollView.frame                                     = CGRect(x: KScreenWidth*CGFloat(i), y: 0, width: KScreenWidth, height: KScreenHeight)
                    scrollView.tag                                       = 210+i
                    self.commodityImageScrollView.addSubview(scrollView)
                    let imageView:UIImageView                        = UIImageView()
                    imageView.bounds                                     = CGRect(x: 0,y: 0, width: KScreenWidth, height: KScreenHeight)
                    imageView.center                                     = CGPoint(x: self.view.center.x, y: self.view.center.y)
                    imageView.contentMode                                = .scaleAspectFit
//                    imageView.autoresizesSubviews = true;
                    
//                    imageView.autoresizingMask = .FlexibleLeftMargin | .FlexibleTopMargin | .FlexibleHeight | .FlexibleWidth
                    
                    //                    imageView.clipsToBounds                              = true
                    imageView.backgroundColor                            = UIColor.RGBColor(242.0, green: 242.0, blue: 242.0)
                    

                    if let url                                           = URL(string: self.commodityImageArray[i]) {
                
                        imageView.kf.setImage(with: url, placeholder: KProductPlaceholderImage, options: nil, progressBlock: nil, completionHandler: nil)

                    }

                    scrollView.addSubview(imageView)
                    imageView.isUserInteractionEnabled                     = true
                    let singleTapGestureRecognizer                       = UITapGestureRecognizer(target: self, action: #selector(CommodityImagesDetailViewController.singleTapGestureRecognizer(_:)))
                    singleTapGestureRecognizer.numberOfTapsRequired      = 1
                    let doubleTapGestureRecognizer                       = UITapGestureRecognizer(target: self, action: #selector(CommodityImagesDetailViewController.doubleTapGestureRecognizer(_:)))
                    doubleTapGestureRecognizer.numberOfTapsRequired      = 2
                    let longpressGesutre                                 = UILongPressGestureRecognizer(target: self, action: #selector(CommodityImagesDetailViewController.handleLongpressGesture(_:)))
                    imageView.tag                                        = 230 + i
                    imageView.addGestureRecognizer(singleTapGestureRecognizer)
                    imageView.addGestureRecognizer(doubleTapGestureRecognizer)
                    imageView.addGestureRecognizer(longpressGesutre)
                    singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
                    
                }
                
                self.commodityImageScrollView.contentOffset             = CGPoint(x: CGFloat(currentPage)*KScreenWidth, y: 0)
                commodityImagePageControl.numberOfPages                 = self.commodityImageArray.count
                commodityImagePageControl.currentPage                   = currentPage
                commodityImagePageControl.frame                         = CGRect(x: 0, y: self.commodityImageScrollView.frame.height-49, width: self.commodityImageScrollView.frame.width, height: 8)
                commodityImagePageControl.currentPageIndicatorTintColor = UIColor.colorWithHexString("#FFC800")
                commodityImagePageControl.pageIndicatorTintColor        = UIColor.colorWithHexString("#ffffff")
                commodityImagePageControl.transform                     = CGAffineTransform(scaleX: 1.0, y: 1.0)
                commodityImagePageControl.hidesForSinglePage            = true
                self.view.addSubview(commodityImagePageControl)
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.commodityImageScrollView {
            let pageWidth : CGFloat = self.commodityImageScrollView.frame.size.width
            let fractionalPage : Double = Double((self.commodityImageScrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1
            let page : Int = lround(fractionalPage)
            if page == 0 {
                self.commodityImagePageControl.currentPage = self.commodityImageArray.count - 1
            }else if page == self.commodityImageArray.count+1 {
                self.commodityImagePageControl.currentPage = 0
            }
            self.commodityImagePageControl.currentPage = page - 1
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.commodityImageScrollView {
            let pageWidth=self.commodityImageScrollView.frame.size.width
            let pageHeigth=self.commodityImageScrollView.frame.size.height
            let fractionalPage : Double = Double((self.commodityImageScrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1
            let page : Int = lround(fractionalPage)
            if page == 0 {
                self.commodityImageScrollView.scrollRectToVisible(CGRect(x: pageWidth*CGFloat(self.commodityImageArray.count), y: 0, width: pageWidth, height: pageHeigth), animated: true)
                self.commodityImagePageControl.currentPage = self.commodityImageArray.count - 1
                return
            }else if page == self.commodityImageArray.count + 1 {
                self.commodityImageScrollView .scrollRectToVisible(CGRect(x: pageWidth, y: 0, width: pageWidth, height: pageHeigth), animated: true)
                self.commodityImagePageControl.currentPage = 0
                return
            }
            self.commodityImagePageControl.currentPage = page-1
//            NJLog("scrollViewDidEndDecelerating")
            if self.commodityImagePageControl.currentPage == 0 && self.commodityImagePageControl.currentPage > 0 {
                let scroll = self.view.viewWithTag(self.commodityImagePageControl.currentPage+211) as! UIScrollView
                if scroll.zoomScale != scroll.minimumZoomScale {
                    scroll.setZoomScale(scroll.minimumZoomScale, animated: false)
                }
//                NJLog(0)
            }else if self.commodityImagePageControl.currentPage > 0 && self.commodityImagePageControl.currentPage < self.commodityImageArray.count-1 {
                let scroll1 = self.view.viewWithTag(self.commodityImagePageControl.currentPage+209) as! UIScrollView
                let scroll2 = self.view.viewWithTag(self.commodityImagePageControl.currentPage+211) as! UIScrollView
                if scroll1.zoomScale != scroll1.minimumZoomScale {
                    scroll1.setZoomScale(scroll1.minimumZoomScale, animated: false)
                }
                if scroll2.zoomScale != scroll2.minimumZoomScale {
                    scroll2.setZoomScale(scroll2.minimumZoomScale, animated: false)
                }
                
//                NJLog(1)
            }else if self.commodityImagePageControl.currentPage == self.commodityImageArray.count-1 && self.commodityImagePageControl.currentPage > 0 {
                let scroll = self.view.viewWithTag(self.commodityImagePageControl.currentPage+209) as! UIScrollView
                if scroll.zoomScale != scroll.minimumZoomScale {
                    scroll.setZoomScale(scroll.minimumZoomScale, animated: false)
                }
            }
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0
        let image = self.view.viewWithTag(scrollView.tag+20) as! UIImageView
        image.center = CGPoint(x: scrollView.contentSize.width/2 + offsetX, y: scrollView.contentSize.height/2 + offsetY)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView != self.commodityImageScrollView {
            let image = self.view.viewWithTag(scrollView.tag+20) as! UIImageView
            return image
        }
        return UIView()
    }
    
    @objc func singleTapGestureRecognizer(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }

    @objc func doubleTapGestureRecognizer(_ sender: UITapGestureRecognizer){
        let image = self.view.viewWithTag(sender.view!.tag) as! UIImageView
        let scroll = self.view.viewWithTag(sender.view!.tag-20) as! UIScrollView
        if scroll.zoomScale != scroll.minimumZoomScale {
            scroll.setZoomScale(scroll.minimumZoomScale, animated: true)
        } else {
            let touchPoint      = sender.location(in: image)
            let image           = image.image
            var maxZoomScale: CGFloat = 3
            let imageSize       = image!.size
            let boundSize       = view.bounds.size
            let xScale          = boundSize.width / imageSize.width
            let yScale          = boundSize.height / imageSize.height
            let minScale        = min(xScale, yScale)
            let maxScale        = max(xScale, yScale)
            if minScale > 1 {
                maxZoomScale    = max(maxZoomScale, maxScale)
            } else {
                maxZoomScale    = max(maxZoomScale, maxScale / minScale)
            }
            let newZoomScale    = maxZoomScale * scroll.minimumZoomScale
            let xsize           = scroll.bounds.size.width / newZoomScale
            let ysize           = scroll.bounds.size.height / newZoomScale
            scroll.zoom(to: CGRect(x: touchPoint.x - xsize/2-50, y: touchPoint.y - ysize/2-50 , width: xsize, height: ysize), animated: true)
        }
    }

    @objc func handleLongpressGesture(_ sender: UITapGestureRecognizer) {
        
        imageView = self.view.viewWithTag(sender.view!.tag) as! UIImageView
        if sender.state == UIGestureRecognizerState.began {
            let _ = YepAlertKit.showAlertView(in: self, title: "保存到相册", message: nil, titles: ["保存"], cancelTitle: "取消", destructive: nil, callBack: {[weak self]  (index) in
                if index == 1 {
                    UIImageWriteToSavedPhotosAlbum((self?.imageView.image!)!, self, nil, nil)
                }
            })
        }
    }
    


    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.black
    }
    
    
}
