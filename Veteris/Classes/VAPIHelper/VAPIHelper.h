//
//  VAPIHelper.h
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "../../Clutch/MobileInstallation.h"
#import "../YZLog/YZLog.h"
#import "../YZAlert/YZAlert.h"

// VAPIHelper should not include any classes to avoid circular imports
@class AppDelegate;

#define getDelegate() ((AppDelegate*)[[UIApplication sharedApplication]delegate])
#define downloadPath() @"/var/mobile/Media/Downloads/Veteris"
#define downloadPathFor(string) [NSString stringWithFormat:@"/var/mobile/Media/Downloads/Veteris/%@.ipa", [string MD5Hash]]
#define VAPISS [VAPIHelper sharedInstance]
//#define alert(title,msg,target) [[[UIAlertView alloc] initWithTitle:title message:msg delegate:target cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]
#define alert(title,msg,typ) [YZAlert alert:title message:msg type:typ]

@interface VAPIHelper : NSObject<NSURLConnectionDelegate>
+ (VAPIHelper *)sharedInstance;
+ (NSString *)getApiStaticURL;
+ (NSString *)getApiBaseURL;
- (void)get:(NSString *)endpoint path:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion;
- (void)getStatic:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion;
- (void)getMessage:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion;
- (UIImage *)imageFromCache:(NSString *)url;
+ (void)checkForUpdates;
+ (NSDictionary *)getHeaders;
+ (void)showWhatsNewIfNeeded;
@property (strong, nonatomic) NSString *VAPIDeviceString;
@end
