//
//  DpkgWrapper.h
//  Sileo
//
//  Created by CoolStar on 6/21/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

#import <Foundation/Foundation.h>

enum pkgwant {
    PKG_WANT_UNKNOWN,
    PKG_WANT_INSTALL,
    PKG_WANT_HOLD,
    PKG_WANT_DEINSTALL,
    PKG_WANT_PURGE,
    /** Not allowed except as special sentinel value in some places. */
    PKG_WANT_SENTINEL,
};

enum pkgeflag {
    PKG_EFLAG_OK        = 0,
    PKG_EFLAG_REINSTREQ    = 1,
};

enum pkgstatus {
    PKG_STAT_NOTINSTALLED,
    PKG_STAT_CONFIGFILES,
    PKG_STAT_HALFINSTALLED,
    PKG_STAT_UNPACKED,
    PKG_STAT_HALFCONFIGURED,
    PKG_STAT_TRIGGERSAWAITED,
    PKG_STAT_TRIGGERSPENDING,
    PKG_STAT_INSTALLED,
};

enum pkgpriority {
    PKG_PRIO_REQUIRED,
    PKG_PRIO_IMPORTANT,
    PKG_PRIO_STANDARD,
    PKG_PRIO_OPTIONAL,
    PKG_PRIO_EXTRA,
    PKG_PRIO_OTHER,
    PKG_PRIO_UNKNOWN,
    PKG_PRIO_UNSET = -1,
};

@interface DpkgWrapper : NSObject
+ (BOOL)getValuesForStatusField:(NSString *)statusField wantInfo:(enum pkgwant *)wantInfo eFlag:(enum pkgeflag *)eFlag status:(enum pkgstatus *)pkgStatus;
@end
