//
//  ControlFileParser.m
//  Sileo
//
//  Created by CoolStar on 6/20/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

#import "ControlFileParser.h"
#import "NSString-TrimLeadingWhitespace.h"

@implementation ControlFileParser
+ (NSDictionary *)dictionaryFromControlFile:(NSString *)controlFile isReleaseFile:(BOOL)isRelease {
    //Normalize CR/LF to LF
    controlFile = [controlFile stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    controlFile = [controlFile stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSArray *controlFileLines = [controlFile componentsSeparatedByString:@"\n"];
    NSString *lastMultilineKey = @"";
    for (NSString *line in controlFileLines){
        NSRange separatorRange = [line rangeOfString:@":"];
        if (separatorRange.location == NSNotFound){
            if ([lastMultilineKey isEqualToString:@""])
                continue;
        }
        NSString *key = separatorRange.location == NSNotFound ? nil : [line substringToIndex:separatorRange.location];
        NSString *value = separatorRange.location == NSNotFound ? nil : [line substringFromIndex:separatorRange.location + 1];
        if (key && ![key containsString:@" "]){
            NSArray *multiLineKeys = @[@"Description"];
            if (isRelease){
                multiLineKeys = @[@"Description", @"MD5Sum", @"SHA1", @"SHA256", @"SHA512"];
            }
            if ([multiLineKeys containsObject:key]){
                lastMultilineKey = key;
            } else {
                lastMultilineKey = @"";
            }
            [dictionary setObject:[value stringByTrimmingLeadingWhitespace] forKey:key];
        } else {
            if (![lastMultilineKey isEqualToString:@""]){
                NSString *newValue = [[dictionary objectForKey:lastMultilineKey] stringByAppendingFormat:@"\n%@",[line stringByTrimmingLeadingWhitespace]];
                [dictionary setObject:newValue forKey:lastMultilineKey];
            }
        }
    }
    return dictionary;
}

+ (NSString *)authorNameFromString:(NSString *)authorString {
    NSString *author = authorString;
    NSRange emailRange = [author rangeOfString:@"<"];
    if (emailRange.location != NSNotFound){
        author = [author substringToIndex:emailRange.location];
    }
    return author;
}

+ (NSString *)authorEmailFromString:(NSString *)authorString {
    NSString *email = authorString;
    NSRange emailRange = [email rangeOfString:@"<"];
    if (emailRange.location != NSNotFound){
        email = [email substringFromIndex:emailRange.location];
        emailRange = [email rangeOfString:@">"];
        if (emailRange.location != NSNotFound){
            email = [email substringToIndex:emailRange.location];
            return email;
        }
    }
    return nil;
}
@end
