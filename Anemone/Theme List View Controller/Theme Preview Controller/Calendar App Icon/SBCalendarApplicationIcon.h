//
//  SBCalendarApplicationIcon.h
//  Anemone
//
//  Created by CoolStar on 1/28/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBCalendarApplicationIcon : NSObject
- (void)drawTextIntoCurrentContextWithImageSize:(CGSize)imageSize iconBase:(UIImage *)base;
@end

NS_ASSUME_NONNULL_END
