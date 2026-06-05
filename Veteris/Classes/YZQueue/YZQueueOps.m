#import "YZQueueOps.h"
#import "../VAPIHelper/VAPIHelper.h"
#import "../../Clutch/MobileInstallation.h"
#import "../../BBHTTP/BBHTTP.h"
#import "../../BBHTTP/BBHTTPRequest+Convenience.h"
#import "../../AppDelegate.h"
#import <MobileCoreServices/LSApplicationWorkspace.h>

@implementation YZQueueOps
#pragma mark - Main Methods
+ (BOOL)installIPA:(NSString *)filePath {
    if (![YZQueueOps doesPathExist:filePath]) {
        debugLog(@"File does not exist at path but skipping: %@", filePath);
        return false;
    }
    int ret;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        ret = MobileInstallationInstall((__bridge CFStringRef)filePath, (__bridge CFDictionaryRef)[NSDictionary dictionaryWithObject:@"User" forKey:@"ApplicationType"], NULL, NULL);
    } else {
        LSApplicationWorkspace *workspace = [LSApplicationWorkspace defaultWorkspace];
        NSError *error;
        [workspace installApplication:[NSURL fileURLWithPath:filePath] withOptions:nil error:&error];
        if (error) {
            debugLog(@"Error: %@", [error localizedDescription]);
        }
        ret = (error == nil) ? 0 : 1;
    }
    [self removeFileAt:filePath];
    return (ret == 0);
}

+ (void)downloadFileToPath:(NSString *)urlString pathFromString:(NSString *)str parent:(YZQueueRep *)parent {
    debugLog(@"Downloading %@", str);
    debugLog(@"URL: %@", urlString);
    BBHTTPRequest *request = [[BBHTTPRequest alloc] initWithTarget:urlString andVerb:@"GET"];
    NSMutableDictionary *reqHeaders = [[VAPIHelper getHeaders] mutableCopy];
    for (id key in reqHeaders) {
        [request setValue:[reqHeaders valueForKey:key] forHeader:key];
    }
    request.connectionTimeout = 900; // 15 minutes
    request.finishBlock = ^(BBHTTPRequest *request) {
        if ([request wasCancelled] || parent.state == YZRepStateCancelled || parent.state == YZRepStateFailed) {
            [self removeFileAt:downloadPathFor(str)];
        } else if ([request hasSuccessfulResponse]) {
            debugLog(@"Downloaded %@", str);
            parent.state = YZRepStateDownloaded;
            parent.path = downloadPathFor(str);
        } else {
            debugLog(@"Failure to download app, error = %@", [request.error localizedDescription]);
            [self removeFileAt:downloadPathFor(str)];
            parent.state = YZRepStateFailed;
        }
    };
    //request.downloadSpeedLimit = 1204; // 256KB/s
    [request downloadToFile:downloadPathFor(str)];
    parent.path = downloadPathFor(str);
    parent.request = request; // this is a weak reference, please check it for nil
    [[BBHTTPExecutor sharedExecutor] executeRequest:request];
}

#pragma mark - Misc Methods
+ (void)removeFileAt:(NSString *)path {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (error) {
        debugLog(@"Error: %@, file already removed?", [error localizedDescription]);
    }
}

+ (void)notifyAppState:(YZQueueRep *)appRep {
    debugLog(@"Notifying app state change for %@, newState: %d", appRep.bundleID, appRep.state);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"YZQueueRepStateChange" object:appRep];
}

+ (BOOL)doesPathExist:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
@end