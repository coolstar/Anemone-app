#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef LaunchServices_h
#define LaunchServices_h

@interface LSApplicationProxy : NSObject
+ (nullable LSApplicationProxy *)applicationProxyForIdentifier:(NSString *_Nullable)arg1;
- (nullable NSURL *)bundleURL;
- (nullable id)_plistValueForKey:(NSString *_Nonnull)key;
- (nullable NSString *)applicationIdentifier;
- (nullable NSString *)localizedName;
- (BOOL)iconIsPrerendered;
- (nullable NSString *)_boundApplicationIdentifier;
- (nullable NSString *)ANEMIdentifier;
- (nullable NSDictionary *)iconsDictionary;
- (void)setAlternateIconName:(nullable NSString *)name withResult:(void (^_Nullable)(bool success, NSError *error))result;
@end

@interface LSApplicationWorkspace : NSObject
+ (nonnull instancetype)defaultWorkspace;
- (nonnull NSArray<LSApplicationProxy *> *)allInstalledApplications;
@end

@interface _LSIconCacheClient : NSObject
+ (nonnull instancetype)sharedInstance;
- (void)invalidateCacheEntriesForBundleIdentifier:(NSString *_Nullable)bundleIdentifier clearAlternateName:(bool)clearAlternateName validationDictionary:(id _Nullable )arg3;
@end

void clearCacheForItem(NSString *_Nullable bundle);
#endif
