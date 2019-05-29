//
//  AnemoneExtensionParameters.h
//  Anemone
//
//  Created by CoolStar on 2/12/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnemoneIconView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, assign) BOOL inDock;

- (void)configureForDisplay;
@end

@interface AnemoneFolderIconView : UIView
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *backdropView;
@property (nonatomic, strong) UIView *backdropOverlayView;
@property (nonatomic, strong) UIView *gridView;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, assign) BOOL inDock;

- (void)configureForDisplay;
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

@interface AnemoneFloatyDockBackgroundView : _UIBackdropView
- (void)configureForDisplay;
@end

@interface AnemoneDockBackgroundView : _UIBackdropView
- (void)configureForDisplay;
@end

@interface AnemoneDockOverlayView : UIView
- (void)configureForDisplay;
@end

@interface AnemoneExtensionParameters : NSObject
+ (BOOL)respringRequired;
+ (UIImage *)kitImageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
