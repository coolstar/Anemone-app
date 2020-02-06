//
//  LaunchServices.h
//  Anemone
//
//  Created by CoolStar on 10/30/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

#import "LaunchServices.h"
#import <objc/runtime.h>

@implementation LSApplicationProxy (Anemone)
- (NSString *)ANEMIdentifier {
    if ([self respondsToSelector:@selector(_boundApplicationIdentifier)])
        return [self _boundApplicationIdentifier];
    return [self applicationIdentifier];
}
@end

void clearCacheForItem(NSString *bundle){
    [(_LSIconCacheClient *)[objc_getClass("_LSIconCacheClient") sharedInstance] invalidateCacheEntriesForBundleIdentifier:bundle clearAlternateName:YES validationDictionary:nil];
}
