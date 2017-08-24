一款不错的图片选择器,支持从相册选取单张或者多张图片,利用delegate和block做为选择完成后的回调.
2支持 iOS8以上系统,基于Photos.framework的封装,完美实现从相册选择图片查看相册图片列表.

CocoaPods集成方式
pod 'CYPhotosKit', '~> 2.6.0'

iOS8以后苹果推出了 Photos.Framework来管理用户相册等多媒体资源,笔者抱着学习的态度仿写了一个多图片选择器,利用 Photos.Framework 来获取相册里的相片视频.

CYPhotosLibrary 获取相册里的分组,查看单个分组里所有相片,单选和多选照片,可以设置最大选择照片的数量.
github地址: https://github.com/ZhaoBingDong/CYPhotosKit

如果要打开设置隐私界面 修改plist文件，在里面添加 URL types 并设置一项URL Schemes为prefs

详细过程可以查看简书

 http://www.jianshu.com/p/dc2c07449d90
示例代码

 let cyPhotoNav                                             = CYPhotoNavigationController.showPhotosViewController()
 self.presentViewController(cyPhotoNav, animated: true, completion: nil)
 cyPhotoNav.maxPickerImageCount       = self.getNeedsImageCount() // 设置最大选去相片的数量,比如最多选择9张照片
 cyPhotoNav.cyPhotosDelegate                = self
 cyPhotoNav.completionBlock     = { (photos) in


  }
  ##  闭包和代理二选一
CYPhotoNavigationControllerDelegate 图片选择器协议

// MARK: - CYPhotoNavigationControllerDelegate
extension BKComposeViewController : CYPhotoNavigationControllerDelegate {

    func cyPhotoNavigationController(controller: CYPhotoNavigationController?, didFinishedSelectPhotos result: [CYPhotosAsset]?) {

        let array   = NSMutableArray()

        for i in 0..<result!.count {

            let photoAsset    = result![i] 
            let photo         = CYPhoto()
            photo.type        = .Photo
            photo.image       = nil
            photo.photosAsset = photoAsset
            array.addObject(photo)

        }

        let indexSet = NSIndexSet.init(indexesInRange: NSMakeRange(0, array.count))
        self.dataSource.insertObjects(array as [AnyObject], atIndexes: indexSet)
        if self.dataSource.count >= 10 {
            self.dataSource.removeLastObject()
        }

        self.collectionView.reloadData()

    }

}
API 文档

CYPhotoNavigationController 图片选择器对象 通过它完成相册所有照片的显示和选择完图片后的回调

@class CYPhotosAsset;
/**
 *  选取完照片的后的回调
 */
typedef void(^PhotosCompletion)(NSArray <CYPhotosAsset*> *_Nullable result);

@protocol CYPhotoNavigationControllerDelegate;
/**
 *  相册选择器的导航控制器
 */
@interface CYPhotoNavigationController : UINavigationController

/**
 *  类方法获取一个 photosNavigationController
 */
+ (_Nonnull instancetype)showPhotosViewController;

/**
 *  禁用 init 方法来生成该类的实例对象
 */
- (_Nonnull instancetype)init UNAVAILABLE_ATTRIBUTE;
/**
 *  禁用 new 方法来生成该类的实例对象
 */
+ (_Nonnull instancetype)new UNAVAILABLE_ATTRIBUTE;

/** completionBlock  */
@property (nonatomic,copy,nullable) PhotosCompletion completionBlock;

/** cyPhotosDelegate */
@property (nonatomic,weak,nullable) id <CYPhotoNavigationControllerDelegate> cyPhotosDelegate;
/**
 *  最大选择图片的数量
 */
@property (nonatomic,assign) NSInteger maxPickerImageCount;

@end

@protocol CYPhotoNavigationControllerDelegate <NSObject,UINavigationControllerDelegate>

@optional

/**
 *  照片选择器完成选择照片
 */
- (void)cyPhotoNavigationController:(CYPhotoNavigationController *_Nullable)controller didFinishedSelectPhotos:(NSArray <CYPhotosAsset*> *_Nullable)result;

@end
CYPhotosAsset 代表一个相片或者一个视频资源

/**
 *  代表一个视频或者照片资源
 */
@interface CYPhotosAsset : NSObject

/** 代表一个图片或者视频 */
@property (nonatomic,strong,nullable) PHAsset *asset;

/** 缩略图  */
@property (nonatomic,strong,nullable) UIImage *thumbnail;

/**  原图  */
@property (nonatomic,strong,nullable) UIImage *originalImg;

/** 视频/图片的本地 url  */
@property (nonatomic,copy,nullable  ) NSURL   *imageUrl;

/** 选取后的图片/视频的二进制文件  */
@property (nonatomic,strong,nullable) NSData *imageData;

@end
CYPhotosCollection 代表一个集合,比如所有照片,最近删除,可以看成单独的某个相册

/**
 *  代表一个集合可能是一个相册组也可能是所有 PHAsset 的集合
 */
@interface CYPhotosCollection : NSObject

/**
 *  集合里边放的是 PHAsset 对象
 */
@property (nonatomic,strong,nullable) PHFetchResult *fetchResult;
/**
 *  相册名称
 */
@property (nonatomic,copy,nullable  ) NSString      *localizedTitle;
/**
 *  相册里照片/视频的熟练
 */
@property (nonatomic,nullable,copy  ) NSString      *count;
/**
 *  相册封面取最新的一张照片作为封面
 */
@property (nonatomic,strong,nullable) UIImage       *thumbnail;

@end
CYPhotosManager 获取相册集合对象 获取所有相册集合 用户自己创建相册集合 系统相册集合

/**
 *  照片资源获取的管理者
 */
@interface CYPhotosManager : NSObject

/**
 *  获取图片资源管理者实例
 */
+ (_Nullable instancetype)defaultManager;

/**
 *  所有照片的集合
 */
- (NSMutableArray <CYPhotosCollection *>*_Nullable)requestAllPhotosOptions;

/**
 *  系统创建的一些相册
 */
- (NSMutableArray <CYPhotosCollection *>*_Nullable)requestSmartAlbums;

/**
 *  用户自己创建的相册
 */
- (NSMutableArray <CYPhotosCollection *>*_Nullable)requestTopLevelUserCollections;
