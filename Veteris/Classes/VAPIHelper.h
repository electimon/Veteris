//
//  VAPIHelper.h
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_ROOT_URL @"https://veteris.yzu.moe"
#define API_STATIC_URL API_ROOT_URL"/static/"
#define API_BASE_URL API_ROOT_URL"/1.1/"

@interface VAPIHelper : NSObject<NSURLConnectionDelegate>
+(NSData *)getVAPIDataForEndpoint:(NSString*)endpoint withHeaders:(NSDictionary *)headers;
+(NSData *)getVAPIDataForEndpoint:(NSString*)endpoint;
+(NSDictionary *)apiGet:(NSString *)endpoint;
+(NSString *)setVAPIDeviceString;
-(BOOL)InstallIPA:(NSData *)data MobileInstallionPath:(NSString *)frameworkPath;
-(void)fetchAndInstallAppForViewController: (NSInteger)appVersionIndex appDictionary:(NSDictionary *)appDictionary withAlertView:(UIAlertView*)senderAlertView;
-(void)stopDownload;
+(void)debugLog:(NSString *)location message:(NSString *)message;
+ (NSDictionary *)apiLogin:(NSString *)username password:(NSString *)password;
+ (NSDictionary *)apiRegister:(NSString *)username password:(NSString *)password;
+ (NSDictionary *)apiReportApp:(NSString *)bundleid version:(NSString *)version reason:(NSString *)reason;
+(NSString*)checkForUpdates;
+ (bool)checkTokenValidity;
typedef void MobileInstallationCallback(CFDictionaryRef information);
typedef int (*MobileInstallationInstall)(NSString *path, NSDictionary *dict, MobileInstallationCallback callback, NSString *backpath);

@property (strong, nonatomic) NSString *VAPIDeviceString;
@end
