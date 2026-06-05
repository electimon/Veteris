//
//  VAPIHelper.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2019-22 Electimon. All rights reserved.
//

#include <Foundation/NSBundle.h>
#include <objc/NSObjCRuntime.h>
#import "../../Clutch/ApplicationLister.h"
#import "VAPIHelper.h"
#import "../Protos/Application.h"
#import <MacTypes.h>
#include <dlfcn.h>
#import <sys/sysctl.h>
#import "../../AppDelegate.h"
#import "../../BBHTTP/BBHTTP.h"
#import "../../BBHTTP/BBHTTPRequest+Convenience.h"
#import "./../AppInfo/AppInfo.h"
#import "../Protos/Version.h"
#import "../Protos/Update.h"
#import "../ProtoStack.h"
#import "../../BBHTTP/Cocoa/BBURLProtocol.h"
#import "BBHTTP/BBHTTPExecutor.h"
#import <arpa/inet.h>
#import <netdb.h>

@implementation VAPIHelper {
    NSCache *_staticCache;
    BBHTTPExecutor *_executor;
    NSInteger _VAPIErrorMask;
}

@synthesize VAPIDeviceString = _deviceString;

static NSString *const API_STATIC_URL = @"https://apis.yzu.moe/veteris/";
static NSString *const API_BASE_URL = @"https://apis.yzu.moe/veteris/1.1/";

+ (VAPIHelper*)sharedInstance
{
    static VAPIHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VAPIHelper alloc] init];
        [sharedInstance setup];
    });
    return sharedInstance;
}

- (void)setup {
    [self setVAPIDeviceString];
    _staticCache = [[NSCache alloc] init];
    [_staticCache setTotalCostLimit:1024 * 1024 * 50]; // 50MB
    _executor = [[BBHTTPExecutor alloc] initWithId:@"VAPIHelper"];
    _executor.maxParallelRequests = 3;
    _executor.manageNetworkActivityIndicator = true;
    NSString *host = [self resolveHost:@"apis.yzu.moe"];
    if (host != nil) {
        [BBHTTPExecutor setResolvePolicy:@"apis.yzu.moe" withIP:host];
    }
}

- (NSString *)resolveHost:(NSString *)host {
    struct hostent *host_entry = gethostbyname([host UTF8String]);
    char *buff;
    buff = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
    if (buff == NULL || strlen(buff) == 0) {
        return nil;
    }
    return [NSString stringWithUTF8String:buff];
}

+ (NSString *)getApiStaticURL {
    return API_STATIC_URL;
}

+ (NSString *)getApiBaseURL {
    return API_BASE_URL;
}


+ (NSDictionary *)getHeaders {
    AppDelegate *delegate = getDelegate();
    return [@{
        @"X-Veteris-Device" : [VAPISS VAPIDeviceString],
        @"X-Veteris-Version" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
        @"X-Veteris-Language" : [[NSLocale preferredLanguages] objectAtIndex:0],
    } mutableCopy];
}

#define VAPI_USE_BBHTTP_DIRECT
#ifdef VAPI_USE_BBHTTP_DIRECT
- (void)get:(NSString *)endpoint path:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *reqHeaders = [VAPIHelper getHeaders];
        BBHTTPRequest *request = [[BBHTTPRequest alloc] initWithTarget:[NSString stringWithFormat:@"%@%@", endpoint, path] andVerb:@"GET"];
        for (id key in reqHeaders) {
            [request setValue:[reqHeaders valueForKey:key] forHeader:key];
        }
        request.finishBlock = ^(BBHTTPRequest *request) {
            if ([request hasSuccessfulResponse] || request.responseStatusCode == 503) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(request.response.content, nil);
                });
            } else {
                debugLog(@"Error occurred: %@", request.error.localizedDescription);
                completion(nil, request.error);
            }
        };
        [request downloadContentAsData];
        [_executor executeRequest:request];
    });
}
#else // has broken network activity indicator
- (void)get:(NSString *)endpoint path:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [endpoint stringByReplacingOccurrencesOfString:@"https" withString:@"bbhttps"], path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *reqHeaders = [VAPIHelper getHeaders];
    for (id key in reqHeaders) {
        [request setValue:[reqHeaders valueForKey:key] forHTTPHeaderField:key];
    }
    [request setHTTPMethod:@"GET"];
    [NSURLProtocol registerClass:[BBURLProtocol class]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (error != nil) {
            debugLog(@"Error occurred: %@", error.localizedDescription);
        }
        completion(data, error);
    }];
}
#endif

// this implements cached version for static assets
// its fine to cache images like this because they are unique per bundleid
- (void)getCached:(NSString *)endpoint path:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion {
    bool isImage = [[path lastPathComponent] rangeOfString:@"png"].location != NSNotFound;
    if (isImage) {
        NSData *cachedData = [_staticCache objectForKey:path];
        if (cachedData != nil) {
            completion(cachedData, nil);
            return;
        }
    }
    [self get:API_STATIC_URL path:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] completion:^(NSData *data, NSError *error){
        if (data != nil && isImage) {
            [_staticCache setObject:data forKey:path];
        }
        completion(data, error);
    }];
}

- (void)getStatic:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion {
    [self getCached:API_STATIC_URL path:path completion:completion];
}

- (void)getMessage:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion {
    [self get:API_BASE_URL path:path completion:completion];
}

- (UIImage *)imageFromCache:(NSString *)url {
    NSData *cachedData = [_staticCache objectForKey:url];
    if (cachedData != nil) {
        return [UIImage imageWithData:cachedData];
    }
    return nil;
}

- (NSString *)getSysInfoByName:(char *)typeSpecifier {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);

    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);

    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (void)setVAPIDeviceString {
    AppDelegate *delegate = getDelegate();
    NSArray *deviceInfo = @[[self getSysInfoByName:"hw.model"], [self getSysInfoByName:"hw.machine"], [[UIDevice currentDevice] systemVersion]];
    _deviceString = [deviceInfo componentsJoinedByString:@"/"];
    debugLog(@"VAPI Device String: %@", _deviceString);
}

+ (void)checkForUpdates {
    [VAPISS getMessage:@"client/updates" completion:^(NSData *data, NSError *error) {
        if (error != nil) {
            debugLog(@"Error contacting server: %@", error.localizedDescription);
            alert(NSLocalizedString(@"Oops", nil), NSLocalizedString(@"ServerContactError", nil), VAPIHelperErrorNetwork);
        } else if (data != nil && [data length] > 1) {
            debugLog(@"Received update data");
            Update *upd = (Update *)CFBridgingRelease(decode([data bytes], [data length], UpdateResponse));
            if (upd == NULL) {
                debugLog(@"Error decoding UpdateMsg");
                return;
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSDictionary dictionaryWithObject:upd.changelog forKey:upd.version] forKey:@"latest_changelog"];
            [defaults synchronize];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Available!" message:[NSString stringWithFormat:@"New version %@ is available! Update now?", upd.version] delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Ok", nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alertView show];
            });
        } else {
            debugLog(@"No data received");
        }
    }];
}

+ (void)showWhatsNewIfNeeded {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *latest_changelog = [defaults objectForKey:@"latest_changelog"];
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        debugLog(@"Latest changelog: %@", latest_changelog);
        debugLog(@"Current version: %@", currentVersion);
        if (latest_changelog != nil && [latest_changelog objectForKey:currentVersion] != nil) {
            NSString *changelog = [latest_changelog objectForKey:currentVersion];
            [YZAlert alert:NSLocalizedString(@"What's New", nil) message:changelog separator:@"\n"];
            [defaults removeObjectForKey:@"latest_changelog"];
            [defaults synchronize];
        } else {
            debugLog(@"No changelog found for current version");
        }
    });
}
@end
