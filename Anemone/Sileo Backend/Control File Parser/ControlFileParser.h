//
//  ControlFileParser.h
//  Sileo
//
//  Created by CoolStar on 6/20/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ControlFileParser : NSObject
+ (NSDictionary *)dictionaryFromControlFile:(NSString *)controlFile isReleaseFile:(BOOL)isRelease;
+ (NSString *)authorNameFromString:(NSString *)authorString;
+ (NSString *)authorEmailFromString:(NSString *)authorString;
@end
