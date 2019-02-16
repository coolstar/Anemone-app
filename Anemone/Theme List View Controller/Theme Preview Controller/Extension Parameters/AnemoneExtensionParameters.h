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

@interface AnemoneExtensionParameters : NSObject
+ (BOOL)respringRequired;
+ (UIImage *)kitImageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
