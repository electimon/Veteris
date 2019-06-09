//
//  VAPIHelper.h
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VAPIHelper : NSObject
+(NSDictionary *)apiGet:(NSString *)endpoint;
+(NSString *)setVAPIDeviceString;
+(BOOL)InstallIPA:(NSString *)ipaPath MobileInstallionPath:(NSString *)frameworkPath;
+ (BOOL)fetchAndInstallApp: (NSString *)appBundleID appDictionary:(NSDictionary *)appDictionary;

typedef int (*MobileInstallationInstall)(NSString *path, NSDictionary *dict, void *na, NSString *backpath);

@property (strong, nonatomic) NSString *VAPIDeviceString;
@end
