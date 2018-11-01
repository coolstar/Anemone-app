//
//  LaunchServices.h
//  Anemone
//
//  Created by CoolStar on 10/30/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

#import "LaunchServices.h"
#import <objc/runtime.h>

void clearCacheForItem(NSString *bundle){
    [(_LSIconCacheClient *)[objc_getClass("_LSIconCacheClient") sharedInstance] invalidateCacheEntriesForBundleIdentifier:bundle clearAlternateName:YES validationDictionary:nil];
}
