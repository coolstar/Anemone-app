//
//  PackageListManager.m
//  Anemone
//
//  Created by CoolStar on 10/28/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

#import "PackageListManager.h"
#import "ControlFileParser.h"
#import "DpkgWrapper.h"

#if TARGET_IPHONE_SIMULATOR
#define TARGET_SANDBOX 1
#endif

@implementation PackageListManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static PackageListManager *sharedPackageListManager = nil;
    dispatch_once(&pred, ^{
        sharedPackageListManager = [[PackageListManager alloc] init];
    });
    return sharedPackageListManager;
}

- (Package *)packageFromDictionary:(NSDictionary *)rawPackage {
    Package *package = [Package new];
    package.package = rawPackage[@"Package"];
    package.name = rawPackage[@"Name"];
    if (!package.name)
        package.name = package.package;
    package.version = rawPackage[@"Version"];
    package.architecture = rawPackage[@"Architecture"];
    package.maintainer = rawPackage[@"Maintainer"];
    if (package.maintainer){
        if (rawPackage[@"Author"])
            package.author = rawPackage[@"Author"];
        else
            package.author = rawPackage[@"Maintainer"];
    }
    
    package.rawControl = rawPackage;
    return package;
}

- (NSString *)dpkgDir {
#if TARGET_SANDBOX
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Test Data"];
#endif
    return @"/var/lib/dpkg/";
}

- (NSDictionary<NSString *, Package *> *)packagesList {
    NSDictionary *packagesList;
    NSString *packagesFile = [[[self dpkgDir] stringByAppendingPathComponent:@"status"] stringByResolvingSymlinksInPath];
    
    if (packagesFile){
        NSMutableDictionary *packagesListMutable = [NSMutableDictionary dictionary];
        NSError *error;
        NSData *rawPackagesData = [NSData dataWithContentsOfFile:packagesFile options:0 error:&error];
        
        if (error)
            return nil;
        if (!error){
            NSUInteger index = 0;
            
            NSMutableData *normalizedData = [rawPackagesData mutableCopy];
            NSData *find = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
            index = normalizedData.length;
            while (index > 0){
                NSRange range = [normalizedData rangeOfData:find options:NSDataSearchBackwards range:NSMakeRange(0, index)];
                NSUInteger newIndex = 0;
                if (range.location == NSNotFound){
                    index = 0;
                    break;
                } else {
                    newIndex = range.location;
                }
                
                void *data = "\n";
                [normalizedData replaceBytesInRange:range withBytes:data length:1];
                index = newIndex;
            }
            
            find = [@"\r" dataUsingEncoding:NSUTF8StringEncoding];
            index = normalizedData.length;
            while (index > 0){
                NSRange range = [normalizedData rangeOfData:find options:NSDataSearchBackwards range:NSMakeRange(0, index)];
                NSUInteger newIndex = 0;
                if (range.location == NSNotFound){
                    index = 0;
                    break;
                } else {
                    newIndex = range.location;
                }
                
                void *data = "\n";
                [normalizedData replaceBytesInRange:range withBytes:data length:1];
                index = newIndex;
            }
            
            
            index = 0;
            NSData *separator = [@"\n\n" dataUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionary];
            
            while (index < normalizedData.length){
                NSRange range = [normalizedData rangeOfData:separator options:0 range:NSMakeRange(index, normalizedData.length - index)];
                NSUInteger newIndex = 0;
                if (range.location == NSNotFound){
                    newIndex = normalizedData.length;
                } else {
                    newIndex = range.location + 2;
                }
                
                NSRange subRange = NSMakeRange(index, newIndex - index);
                
                NSData *packageData = [normalizedData subdataWithRange:subRange];
                NSString *rawPackageControl = [[NSString alloc] initWithData:packageData encoding:NSUTF8StringEncoding];
                
                NSDictionary *rawPackage = [ControlFileParser dictionaryFromControlFile:rawPackageControl isReleaseFile:NO];
                if ([rawPackage[@"Package"] hasPrefix:@"gsc."]){
                    index = newIndex;
                    continue;
                }
                if ([rawPackage[@"Package"] hasPrefix:@"cy+"]){
                    index = newIndex;
                    continue;
                }
                if ([rawPackage[@"Package"] isEqualToString:@""]){
                    index = newIndex;
                    continue;
                }
                if (!rawPackage[@"Package"]){
                    index = newIndex;
                    continue;
                }
                Package *package = [self packageFromDictionary:rawPackage];
                
                enum pkgwant wantInfo;
                enum pkgeflag eFlag;
                enum pkgstatus status;
                
                BOOL statusValid = [DpkgWrapper getValuesForStatusField:package.rawControl[@"Status"] wantInfo:&wantInfo eFlag:&eFlag status:&status];
                if (!statusValid)
                    continue;
                
                package.wantInfo = wantInfo;
                package.eFlag = eFlag;
                package.status = status;
                
                if (package.eFlag == PKG_EFLAG_OK){
                    if (package.status == PKG_STAT_NOTINSTALLED || package.status == PKG_STAT_CONFIGFILES){
                        index = newIndex;
                        continue;
                    }
                }
                
                [packagesListMutable setObject:package forKey:package.package];
                
                index = newIndex;
            }
            [tempDictionary removeAllObjects];
        }
        packagesList = packagesListMutable;
    }
    
    return packagesList;
}

- (NSString *)prefixDir {
#if TARGET_SANDBOX
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Test Themes"];
#else
    return @"/Library/Themes";
#endif
}

- (NSMutableDictionary<NSString *, NSArray *> *)scanForThemes {
#if TARGET_SANDBOX
    NSArray *themesDirContents = @[@"Amury Alt Apple Icons.theme", @"Amury Alt Icons.theme",
                                    @"Amury Apple Music Icon.theme", @"Amury Control Center.theme",
                                    @"Amury Icons.theme", @"Amury Interface.theme",
                                    @"Amury Keyboard Sounds.theme", @"Amury Legacy Icons.theme",
                                    @"Amury Messages.theme", @"Felicity iOS 11.theme",
                                    @"Felicity.theme", @"iOS 7-10 icons.theme", @"iOS 8 Music Icon.theme "];
#else
    NSArray *themesDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self prefixDir] error:nil];
#endif
    NSMutableArray *themesFolders = [NSMutableArray array];
    NSString *prefixDir = @"/Library/Themes/";
    for (NSString *folder in themesDirContents){
        NSString *fullPath = [prefixDir stringByAppendingPathComponent:folder];
        [themesFolders addObject:fullPath];
    }
    
    NSMutableDictionary *themeIdentifiers = [NSMutableDictionary dictionary];
    
    NSString *contentsFilesPath = [[[self dpkgDir] stringByAppendingPathComponent:@"info"] stringByResolvingSymlinksInPath];
    NSArray *contentsFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:contentsFilesPath error:nil];
    for (NSString *packageFile in contentsFiles){
        if (![packageFile hasSuffix:@".list"])
            continue;
        NSString *fullPath = [contentsFilesPath stringByAppendingPathComponent:packageFile];
        NSString *contents = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
        
        NSArray *files = [contents componentsSeparatedByString:@"\n"];
        
        NSMutableArray *itemsToRemove = [NSMutableArray array];
        
        for (NSString *themePath in themesFolders){
            if ([files containsObject:themePath]){
                NSString *packageId = [packageFile stringByDeletingPathExtension];
                NSMutableArray *paths = [themeIdentifiers objectForKey:packageId];
                if (!paths){
                    paths = [NSMutableArray array];
                    [themeIdentifiers setObject:paths forKey:packageId];
                }
                [paths addObject:[themePath lastPathComponent]];
                [itemsToRemove addObject:themePath];
            }
        }
        for (NSString *item in itemsToRemove){
            [themesFolders removeObject:item];
        }
    }
    
    for (NSString *themePath in themesFolders){
        NSString *packageId = @"com.anemonetheming.unknown";
        NSMutableArray *paths = [themeIdentifiers objectForKey:packageId];
        if (!paths){
            paths = [NSMutableArray array];
            [themeIdentifiers setObject:paths forKey:packageId];
        }
        [paths addObject:[themePath lastPathComponent]];
    }
    return themeIdentifiers;
}

@end
