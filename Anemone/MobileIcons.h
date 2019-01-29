//
//  MobileIcons.h
//  Anemone
//
//  Created by CoolStar on 1/27/19.
//  Copyright © 2019 CoolStar. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#ifndef MobileIcons_h
#define MobileIcons_h

UIImage *getIconForBundle(NSBundle *bundle, NSDictionary *iconsDictionary, int variant, int options, CGFloat scale, BOOL getThemedIcon);

#endif /* MobileIcons_h */
