#import <Foundation/Foundation.h>

@interface LSApplicationProxy : NSObject
- (NSString *)_boundApplicationIdentifier;
- (NSDictionary *)iconsDictionary;
- (void)setAlternateIconName:(NSString *)name withResult:(void (^)(bool success))result;
@end

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (NSArray<LSApplicationProxy *> *)allInstalledApplications;
@end

@interface _LSIconCacheClient : NSObject
+ (instancetype)sharedInstance;
- (void)invalidateCacheEntriesForBundleIdentifier:(NSString *)bundleIdentifier clearAlternateName:(bool)clearAlternateName validationDictionary:(id)arg3;
@end

void clearCacheForItem(NSString *bundle);
