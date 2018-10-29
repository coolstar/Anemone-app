//
//  Package.h
//  Sileo
//
//  Created by CoolStar on 6/21/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DpkgWrapper.h"

@interface Package : NSObject
@property (nonatomic, strong) NSString *package;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *architecture;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *maintainer;
@property (nonatomic, strong) NSString *section;
@property (nonatomic, strong) NSDictionary *rawControl;

@property (nonatomic, assign) enum pkgwant wantInfo;
@property (nonatomic, assign) enum pkgeflag eFlag;
@property (nonatomic, assign) enum pkgstatus status;
@end
