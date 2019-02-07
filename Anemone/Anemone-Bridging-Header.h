//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <UIKit/UIKit.h>
#import "PackageListManager.h"
#import "NSTask.h"
#import "LaunchServices.h"
#import "AppSupport.h"
#import "MobileIcons.h"
#import "AnemoneTweakBridge.h"
#import "SBCalendarApplicationIcon.h"

CFArrayRef (*anem_CPBitmapCreateImagesFromData)(CFDataRef cpbitmap, void*, int, void*);

@interface UIApplication(Private)
- (void)suspend;
@end

@interface UIStatusBar : UIView
- (void)requestStyle:(UIStatusBarStyle)style;
@end

@interface _UIBackdropViewSettings : NSObject
+ (_UIBackdropViewSettings *)settingsForStyle:(int)style;
+ (_UIBackdropViewSettings *)settingsForStyle:(int)style graphicsQuality:(int)graphicsQuality;

@property (nonatomic, retain) UIImage *filterMaskImage;
@property (nonatomic, retain) UIImage *colorTintMaskImage;
@property (nonatomic, retain) UIImage *grayscaleTintMaskImage;
@property (nonatomic, retain) UIImage *darkeningTintMaskImage;
@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, copy) NSString *blurQuality;
@property (nonatomic, assign) NSInteger graphicsQuality;
@property (nonatomic, assign) BOOL explicitlySetGraphicsQuality;
@end

@interface _UIBackdropView : UIView
- (id)initWithFrame:(CGRect)frame autosizesToFitSuperview:(BOOL)autosizesToFitSuperview settings:(_UIBackdropViewSettings *)settings;
@end

@interface UIImage (Private)
- (UIImage *)_applicationIconImageForFormat:(int)arg1 precomposed:(BOOL)arg2 scale:(CGFloat)arg3;
+ (UIImage *) imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (UIImage *)kitImageNamed:(NSString *)imageName;
+ (UIImage *)_iconForResourceProxy:(LSApplicationProxy *)arg1 variant:(int)arg2 variantsScale:(CGFloat)arg3;
+ (int)_iconVariantForUIApplicationIconFormat:(int)arg1 idiom:(UIUserInterfaceIdiom)arg2 scale:(CGFloat*)arg3;
@end

@interface _UIAssetManager : NSObject
+ (nullable _UIAssetManager *)assetManagerForBundle:(NSBundle *)bundle;
@property (readonly) NSBundle *bundle;
@property (readonly) NSString *carFileName;
- (nullable UIImage *)imageNamed:(NSString *)name;
@end
