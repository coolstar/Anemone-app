//
//  DpkgWrapper.m
//  Sileo
//
//  Created by CoolStar on 6/21/18.
//  Copyright © 2018 CoolStar. All rights reserved.
//

#import "DpkgWrapper.h"

struct namevalue {
    char name[32];
    int value;
};

const struct namevalue priorityinfos[] = {
    {"required", PKG_PRIO_REQUIRED},
    {"important", PKG_PRIO_IMPORTANT},
    {"standard", PKG_PRIO_STANDARD},
    {"optional", PKG_PRIO_OPTIONAL},
    {"extra", PKG_PRIO_EXTRA},
    {"unknown", PKG_PRIO_UNKNOWN}
};

const struct namevalue wantinfos[] = {
    {"unknown", PKG_WANT_UNKNOWN},
    {"install", PKG_WANT_INSTALL},
    {"hold", PKG_WANT_HOLD},
    {"deinstall", PKG_WANT_DEINSTALL},
    {"purge", PKG_WANT_PURGE}
};

const struct namevalue eflaginfos[] = {
    {"ok", PKG_EFLAG_OK},
    {"reinstreq", PKG_EFLAG_REINSTREQ}
};

const struct namevalue statusinfos[] = {
    {"not-installed", PKG_STAT_NOTINSTALLED},
    {"config-files", PKG_STAT_CONFIGFILES},
    {"half-installed", PKG_STAT_HALFINSTALLED},
    {"unpackad", PKG_STAT_UNPACKED},
    {"half-configured", PKG_STAT_HALFCONFIGURED},
    {"triggers-awaited", PKG_STAT_TRIGGERSAWAITED},
    {"triggers-pending", PKG_STAT_TRIGGERSPENDING},
    {"installed", PKG_STAT_INSTALLED}
};

@implementation DpkgWrapper
+ (BOOL)getValuesForStatusField:(NSString * _Nullable )statusField wantInfo:(enum pkgwant *)wantInfo eFlag:(enum pkgeflag *)eFlag status:(enum pkgstatus *)pkgStatus {
    NSArray *statusParts = [statusField componentsSeparatedByString:@" "];
    if (statusParts.count < 3)
        return NO;
    if (wantInfo)
        *wantInfo = PKG_WANT_UNKNOWN;
    
    for (int i = 0; i < (sizeof(wantinfos)/sizeof(struct namevalue)); i++){
        if (strcmp(wantinfos[i].name, [statusParts[0] UTF8String]) == 0){
            if (wantInfo)
                *wantInfo = wantinfos[i].value;
        }
    }
    for (int i = 0; i < (sizeof(eflaginfos)/sizeof(struct namevalue)); i++){
        if (strcmp(eflaginfos[i].name, [statusParts[1] UTF8String]) == 0){
            if (eFlag)
                *eFlag = eflaginfos[i].value;
        }
    }
    for (int i = 0; i < (sizeof(statusinfos)/sizeof(struct namevalue)); i++){
        if (strcmp(statusinfos[i].name, [statusParts[2] UTF8String]) == 0){
            if (pkgStatus)
                *pkgStatus = statusinfos[i].value;
        }
    }
    return YES;
}
@end
