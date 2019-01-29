#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef LaunchServices_h
#define LaunchServices_h

@interface LSApplicationProxy : NSObject
+ (nullable LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)arg1;
- (NSURL *)bundleURL;
- (id)_plistValueForKey:(NSString *)key;
- (NSString *)applicationIdentifier;
- (NSString *)localizedName;
- (BOOL)iconIsPrerendered;
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
#endif
