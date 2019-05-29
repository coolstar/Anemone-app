#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef LaunchServices_h
#define LaunchServices_h

@interface LSApplicationProxy : NSObject
+ (nullable LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)arg1;
- (nullable NSURL *)bundleURL;
- (nullable id)_plistValueForKey:(NSString *)key;
- (nullable NSString *)applicationIdentifier;
- (nullable NSString *)localizedName;
- (BOOL)iconIsPrerendered;
- (nullable NSString *)_boundApplicationIdentifier;
- (nullable NSDictionary *)iconsDictionary;
- (void)setAlternateIconName:(nullable NSString *)name withResult:(void (^)(bool success))result;
@end

@interface LSApplicationWorkspace : NSObject
+ (nonnull instancetype)defaultWorkspace;
- (nonnull NSArray<LSApplicationProxy *> *)allInstalledApplications;
@end

@interface _LSIconCacheClient : NSObject
+ (nonnull instancetype)sharedInstance;
- (void)invalidateCacheEntriesForBundleIdentifier:(NSString *)bundleIdentifier clearAlternateName:(bool)clearAlternateName validationDictionary:(id)arg3;
@end

void clearCacheForItem(NSString *_Nullable bundle);
#endif
