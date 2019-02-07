//
//  MobileIcons.m
//  Anemone
//
//  Created by CoolStar on 1/27/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

#import "MobileIcons.h"
#import <dlfcn.h>

CFTypeRef CGImageGetProperty(CGImageRef, CFTypeRef);

UIImage *getIconForBundle(NSBundle *bundle, NSDictionary *__nullable iconsDictionary, int variant, int options, CGFloat scale, BOOL getThemedIcon) {
    void *MobileIcons = dlopen("/System/Library/PrivateFrameworks/MobileIcons.framework/MobileIcons", RTLD_NOW);
    CGImageRef (*_LICreateIconForBundleWithIconNameAndDisplayGamut)(CFBundleRef bundle, CFStringRef iconName, int variant, int deviceSubtype, int options) = dlsym(MobileIcons, "_LICreateIconForBundleWithIconNameAndDisplayGamut");
    CGImageRef (*_LICreateIconForBundleWithIconsDictionaryAndContainers)(CFBundleRef bundle, CFDictionaryRef iconDictionary, CFStringRef iconName, int reserved, int reserved2, int variant, int options) = dlsym(MobileIcons, "_LICreateIconForBundleWithIconsDictionaryAndContainers");
    
    CFBundleRef cfbundle = CFBundleCreate(kCFAllocatorDefault, (CFURLRef)bundle.bundleURL);
    
    CFStringRef iconName = CFSTR("CFBundlePrimaryIcon");
    if (getThemedIcon){
        iconName = CFSTR("__ANEM__AltIcon");
    }
    
    CGImageRef cgImage = nil;
    if (!getThemedIcon && _LICreateIconForBundleWithIconNameAndDisplayGamut){ //iOS 11 only
        cgImage = _LICreateIconForBundleWithIconNameAndDisplayGamut(cfbundle, CFSTR("AppIcon"), variant, 0, options);
        CFTypeRef isDefaultIcon = CGImageGetProperty(cgImage, CFSTR("MobileIcons.IsDefaultIcon"));
        if (isDefaultIcon && CFGetTypeID(isDefaultIcon) == CFBooleanGetTypeID()){
            if (CFBooleanGetValue(isDefaultIcon) == true){
                cgImage = nil;
            }
        }
    }
    
    if (!cgImage){
        cgImage = _LICreateIconForBundleWithIconsDictionaryAndContainers(cfbundle, (__bridge CFDictionaryRef)iconsDictionary, iconName, 0, 0, variant, options);
        if (getThemedIcon){
            CFTypeRef isDefaultIcon = CGImageGetProperty(cgImage, CFSTR("MobileIcons.IsDefaultIcon"));
            if (isDefaultIcon && CFGetTypeID(isDefaultIcon) == CFBooleanGetTypeID()){
                if (CFBooleanGetValue(isDefaultIcon) == true){
                    cgImage = nil;
                }
            }
        }
    }
    if (!cgImage)
        return nil;
    return [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];
}
