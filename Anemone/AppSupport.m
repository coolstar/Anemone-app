//
//  AppSupport.m
//  Anemone
//
//  Created by CoolStar on 1/27/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

#import "AppSupport.h"
#import <dlfcn.h>

#if TARGET_IPHONE_SIMULATOR
#define springboardPath [[[[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]  stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Library/SpringBoard/"]
#else
#define springboardPath [@"/var/mobile/" stringByAppendingPathComponent:@"Library/SpringBoard/"]
#endif

UIImage *getWallpaper(void){
    void *appsupport = dlopen("/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport", RTLD_NOW);
    CFArrayRef (*anem_CPBitmapCreateImagesFromData)(CFDataRef cpbitmap, void*, int, void*);
    *(void **)(&anem_CPBitmapCreateImagesFromData) = dlsym(appsupport, "CPBitmapCreateImagesFromData");
    
    NSString *bgPath = [springboardPath stringByAppendingPathComponent:@"HomeBackground.cpbitmap"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:bgPath])
        bgPath = [springboardPath stringByAppendingPathComponent:@"LockBackground.cpbitmap"];
    
    NSArray *images = (__bridge NSArray *)(anem_CPBitmapCreateImagesFromData((__bridge CFDataRef)([NSData dataWithContentsOfFile:bgPath]), NULL, 1, NULL));
    return [UIImage imageWithCGImage:(CGImageRef)[images objectAtIndex:0]];
}
