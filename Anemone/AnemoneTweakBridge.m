//
//  AnemoneTweakBridge.m
//  Anemone
//
//  Created by CoolStar on 1/27/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>

@interface ANEMSettingsManager : NSObject
+ (instancetype)sharedManager;
- (void)forceReloadNow;

- (BOOL)onlyLoadThemedCGImages;
- (void)setOnlyLoadThemedCGImages:(BOOL)load;

- (BOOL)isCGImageHookEnabled;
- (void)setCGImageHookEnabled:(BOOL)enabled;

- (BOOL)masksOnly;
@end

@interface IBTheme : NSObject
+ (void)resetThemes;
@end

void enableThemes(void){
    dlopen("/usr/lib/TweakInject/AnemoneCore.dylib", RTLD_NOW);
    dlopen("/usr/lib/TweakInject/AnemoneIcons.dylib", RTLD_NOW);
    dlopen("/usr/lib/TweakInject/Anemone.dylib", RTLD_NOW);
    [[objc_getClass("ANEMSettingsManager") sharedManager] forceReloadNow];
    [objc_getClass("IBTheme") resetThemes];
    [[objc_getClass("ANEMSettingsManager") sharedManager] setCGImageHookEnabled:YES];
}

void disableThemes(void){
    [[objc_getClass("ANEMSettingsManager") sharedManager] setCGImageHookEnabled:NO];
}
