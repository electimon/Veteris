//
//  VAPIHelper.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2019-22 Electimon. All rights reserved.
//

#import "VAPIHelper.h"
#import "../AppDelegate.h"
#import <sys/sysctl.h>
#include <dlfcn.h>
#import "../SVProgressHUD/SVProgressHUD.h"
#import "../KeychainItemWrapper.h"

#define TEMP_IPA_PATH "/var/mobile/Media/Downloads/temp.ipa"

@implementation VAPIHelper {
    long downloadSize;
    float downloadProgress;
    NSMutableData *downloadContent;
    NSOperationQueue *queue;
    NSURLConnection *connection;
    UIAlertView *alertView;
}

+(NSData *)getVAPIDataForEndpoint:(NSString*)endpoint withHeaders:(NSDictionary *)headers {
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSURL *currentAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", appdelegate.apiRootURL, endpoint]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:currentAPIURL];
    [request setHTTPMethod:@"GET"];
    if (headers) {
        NSMutableDictionary *requiredHeaders = [@{
            @"X-Veteris-Device": appdelegate.VAPIDeviceString,
            @"X-Veteris-Version": appVersion
        } mutableCopy];
        [requiredHeaders addEntriesFromDictionary:headers];
        request.allHTTPHeaderFields = requiredHeaders;
    } else {
        [request setValue:appdelegate.VAPIDeviceString forHTTPHeaderField:@"X-Veteris-Device"];
        [request setValue:appVersion forHTTPHeaderField:@"X-Veteris-Version"];
    }
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    return data;
}

+(NSData *)getVAPIDataForEndpoint:(NSString*)endpoint {
    return [self getVAPIDataForEndpoint:endpoint withHeaders:nil];
}

+ (NSDictionary *)apiGet:(NSString *)endpoint  {
    NSData *data = [self getVAPIDataForEndpoint:endpoint];
    NSError *error;
    
    if (data == nil) {
        return nil;
    }
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return responseDict;
}

+ (NSDictionary *)apiRegister:(NSString *)username password:(NSString *)password  {
    NSError *error;
    NSDictionary *headers = @{
        @"username": username, @"password": password
    };
    NSData *data = [self getVAPIDataForEndpoint:@"/users/add" withHeaders:headers];

    if (data == nil) {
        return nil;
    }
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return responseDict;
}

+ (NSDictionary *)apiLogin:(NSString *)username password:(NSString *)password {
    NSError *error;
    NSDictionary *headers = @{
        @"username": username,
        @"password": password
    };
    NSData *data = [self getVAPIDataForEndpoint:@"/users/token" withHeaders:headers];
    
    if (data == nil) {
        return nil;
    }
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return responseDict;
}

+ (NSDictionary *)apiReportApp:(NSString *)bundleid version:(NSString *)version reason:(NSString *)reason {    NSError *error;
    //NSString *token = [[NSString alloc] initWithData:[appdelegate.keychain objectForKey:CFBridgingRelease(kSecValueData)] encoding:NSUTF8StringEncoding];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults valueForKey:@"token"];
    //NSString *username = [appdelegate.keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString *username = [defaults valueForKey:@"username"];
    NSDictionary *headers = @{
        @"bundleid": bundleid,
        @"version": version,
        @"reason": reason,
        @"username": username,
        @"token": token
    };
    
    NSData *data = [self getVAPIDataForEndpoint:@"/report" withHeaders:headers];
    
    if (data == nil) {
        return nil;
    }
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return responseDict;
}

-(void)fetchAndInstallAppForViewController: (NSInteger)appVersionIndex appDictionary:(NSDictionary *)appDictionary withAlertView:(UIAlertView*)senderAlertView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    alertView = senderAlertView;
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    downloadSize = 0;
    downloadProgress = 0;
    downloadContent = nil;
    NSURL *currentAPIURL = [[NSURL alloc] init];
    NSDictionary *filePathDict = [[appDictionary objectForKey:@"versions"] objectAtIndex:appVersionIndex];
    NSString *filePath = [[filePathDict allValues] objectAtIndex:0];
    currentAPIURL = [NSURL URLWithString:[[NSString stringWithFormat:@"%s/%@", API_ROOT_URL, filePath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:currentAPIURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:appdelegate.VAPIDeviceString forHTTPHeaderField:@"X-Veteris-Device"];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [connection start];
}

-(void)stopDownload {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [connection cancel];
}

-(BOOL)InstallIPA:(NSData *)data MobileInstallionPath:(NSString *)frameworkPath
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    void *lib = dlopen([frameworkPath UTF8String], RTLD_LAZY);
    puts(dlerror());
    if (lib)
    {
        MobileInstallationInstall pMobileInstallationInstall = (MobileInstallationInstall)dlsym(lib, "MobileInstallationInstall");
        if (pMobileInstallationInstall)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Dismiss here
                [alertView dismissWithClickedButtonIndex:1 animated:NO];
                [SVProgressHUD showWithStatus:@"Copying..." maskType:SVProgressHUDMaskTypeBlack];
                delegate.downloadingBool = false;
                delegate.installingBool = true;
            });
            NSString* temp = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"Temp_" stringByAppendingString:[NSString stringWithFormat:@"%u", arc4random_uniform(1000000)]]];
            NSError *error;
            [data writeToFile:temp options:NSDataWritingAtomic error:&error];
            if (error) {
                [VAPIHelper debugLog:@"VAPIHelper" message:@"Failed to write IPA to temp file"];
                return NO;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:@"Installing..." maskType:SVProgressHUDMaskTypeBlack];
            });
            int ret = pMobileInstallationInstall(temp, [NSDictionary dictionaryWithObject:@"User" forKey:@"ApplicationType"], &installCallback, NULL);
            alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            if (ret == 0)   {
                [VAPIHelper debugLog:@"VAPIHelper" message:@"InstallIPA installed successfully!"];
                delegate.installingBool = false;
                [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
                alertView.title = @"Success!";
                alertView.message = @"Application installed successfully!";
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    delegate.navigationController.topViewController.view.userInteractionEnabled = true;
                    delegate.navigationController.tabBarController.view.userInteractionEnabled = true;
                    [alertView show];
                });
                return YES;
            } else {
                [VAPIHelper debugLog:@"VAPIHelper" message:@"Failed to install IPA..."];
                delegate.installingBool = false;
                [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
                alertView.title = @"Failure";
                alertView.message = @"Application failed to install...";
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    delegate.navigationController.topViewController.view.userInteractionEnabled = true;
                    delegate.navigationController.tabBarController.view.userInteractionEnabled = true;
                    [alertView show];
                });
                return NO;
            }
        }
    }
    else {
        return NO;
    }
    return NO;
}

+ (NSString *)setVAPIDeviceString {
    NSString *VAPIDeviceString;
    NSArray *deviceInfo = @[[AppDelegate getSysInfoByName:"hw.model"], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]];
    VAPIDeviceString = [deviceInfo componentsJoinedByString:@"/"];
    [VAPIHelper debugLog:@"VAPIHelper" message:[NSString stringWithFormat:@"VAPIDeviceString = %@", VAPIDeviceString]];
    return VAPIDeviceString;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *_response = (NSHTTPURLResponse *)response;
    if ([_response statusCode] == 200) {
        downloadSize = [_response expectedContentLength];
        [SVProgressHUD showProgress:downloadProgress status:@"Downloading..." maskType:SVProgressHUDMaskTypeBlack];
    } else {
        alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to connect to the server!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [SVProgressHUD dismiss];
        [alertView show];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!downloadContent){
        downloadContent = [NSMutableData new];
    }
    [downloadContent appendData:data];
    downloadProgress = ((float)[downloadContent length] / (float)downloadSize);
    [SVProgressHUD showProgress:downloadProgress status:@"Downloading..." maskType:SVProgressHUDMaskTypeBlack];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.downloadingBool = false;
    [SVProgressHUD dismiss];
    [alertView show];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (!queue)
        queue = [[NSOperationQueue alloc] init];
    [VAPIHelper debugLog:@"VAPIHelper" message:@"App downloaded sucessfully!"];
    [queue addOperationWithBlock:^{
        [self InstallIPA:downloadContent MobileInstallionPath:@"/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation"];

    }];
}

// Mystical install progress callback code, don't stare for too long or it'll stop working
void installCallback(CFDictionaryRef information) {
    NSDictionary *dict = (__bridge NSDictionary*)information;
    float percentDone = [[dict valueForKey:@"PercentComplete"] floatValue]/100;
    NSString *status = [dict valueForKey:@"Status"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showProgress:percentDone status:status maskType:SVProgressHUDMaskTypeBlack];
    });
}

+(void)debugLog:(NSString *)location message:(NSString *)message {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (delegate.debugOn == [NSNumber numberWithBool:YES]) {
        NSLog(@"%@: %@", location, message);
    }
}

+(NSString*)checkForUpdates {
    NSError *error;
    NSData *data = [self getVAPIDataForEndpoint:@"client/updates"];
    
    if (data == nil) {
        return nil;
    }
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *response = [responseDict valueForKey:@"message"];
    if ([response isEqual:@"No Updates Available!"]) {
        return nil;
    } else if ([response isEqual:@"Update Available!"]) {
        return [[responseDict objectForKey:@"content"] valueForKey:@"version"];
    }
    return nil;                
}

+ (bool)checkTokenValidity {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults valueForKey:@"token"];
    NSString *username = [defaults valueForKey:@"username"];
    NSDictionary *headers = @{
        @"username": username,
        @"token": token
    };
    NSData *data = [self getVAPIDataForEndpoint:@"/users/token/validate" withHeaders:headers];
    
    if (data == nil) {
        // Return true here so we don't decimate the token if server cannot be contacted lmfao
        [self debugLog:@"checkTokenValidity" message:@"Token check data returned nil, skipping"];
        return true;
    }
    
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    if ([[responseDict valueForKey:@"status"] isEqual:@"Success"]) {
        return true;
    } else {
        return false;
    }
}
@end

