//
//  AnemoneExtensionParameters.m
//  Anemone
//
//  Created by CoolStar on 2/12/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

#import "AnemoneExtensionParameters.h"


@interface UIImage(Private)
+ (UIImage *)kitImageNamed:(NSString *)imageName;
@end

@implementation AnemoneIconView
- (void)configureForDisplay {
    
}
@end

@implementation AnemoneExtensionParameters
+ (UIImage *)kitImageNamed:(NSString *)name {
    return [UIImage kitImageNamed:name];
}

+ (BOOL)respringRequired {
    return NO;
}
@end
