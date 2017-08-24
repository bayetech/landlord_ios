//
//  CYPhoto.swift
//  BayeSocial
//
//  Created by 董招兵 on 2017/3/31.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Photos
import CYPhotosKit

enum CYPhotoAssetType : Int {
    case add = 1
    case photo
}

class CYPhoto : NSObject {
    var image : UIImage?
    var asset : PHAsset?
    var photosAsset : CYPhotosAsset? {
        didSet {
            self.asset = photosAsset?.asset
        }
    }
    var type : CYPhotoAssetType = .add
    override init() {
        
    }
}
