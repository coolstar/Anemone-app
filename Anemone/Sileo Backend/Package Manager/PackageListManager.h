//
//  PackageListManager.h
//  Sileo
//
//  Created by CoolStar on 6/21/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Package.h"

@interface PackageListManager : NSObject
+ (nonnull instancetype)sharedInstance;
- (nonnull NSDictionary<NSString *,Package *> *)packagesList;
- (nonnull NSMutableDictionary<NSString *, NSArray *> *)scanForThemes;
@end
