//
//  VAPIHelper.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "VAPIHelper.h"
#import "../AppDelegate.h"
#import <sys/sysctl.h>
#include <dlfcn.h>

#define API_BASE_URL "https://api.veteris.xyz/1.0/"
#define TEMP_IPA_PATH "/var/mobile/Media/Downloads/temp.ipa"

@implementation VAPIHelper

+ (NSDictionary *)apiGet:(NSString *)endpoint {
    
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    
    NSURL *currentAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@", API_BASE_URL, endpoint]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:currentAPIURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:appdelegate.VAPIDeviceString forHTTPHeaderField:@"X-Veteris-Device"];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *tempDict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    
    
    return tempDict;
}

+ (BOOL)fetchAndInstallApp: (NSString *)appBundleID appDictionary:(NSDictionary *)appDictionary {
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    
    NSURL *currentAPIURL = [[NSURL alloc] init];
    
    currentAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%sdownload/%@/%@", API_BASE_URL, appBundleID, [[[appDictionary objectForKey:@"versions"] valueForKey:@"version"] objectAtIndex:0]]];
    
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:currentAPIURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:appdelegate.VAPIDeviceString forHTTPHeaderField:@"X-Veteris-Device"];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *tempDict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    
    currentAPIURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [tempDict valueForKey:@"download"]]];
    
    [request setURL:currentAPIURL];
    
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:@TEMP_IPA_PATH]) system("rm /var/mobile/Media/Downloads/temp.ipa");
    
    [data writeToFile:@TEMP_IPA_PATH atomically:YES];
    
    return [self InstallIPA:@"/var/mobile/Media/Downloads/temp.ipa" MobileInstallionPath:@"/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation"];
}

+(BOOL)InstallIPA:(NSString *)ipaPath MobileInstallionPath:(NSString *)frameworkPath
{
    
    void *lib = dlopen([frameworkPath UTF8String], RTLD_LAZY);
    puts(dlerror());
    if (lib)
    {
        MobileInstallationInstall pMobileInstallationInstall = (MobileInstallationInstall)dlsym(lib, "MobileInstallationInstall");
        if (pMobileInstallationInstall)
        {
            NSString* temp = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"Temp_" stringByAppendingString:ipaPath.lastPathComponent]];
            if (![[NSFileManager defaultManager] copyItemAtPath:ipaPath toPath:temp error:nil]) {
                NSLog(@"VAPIHelper: InstallIPA failed to copy ipa to temp!");
                return NO;
            }
            int ret = pMobileInstallationInstall(ipaPath, [NSDictionary dictionaryWithObject:@"User" forKey:@"ApplicationType"], 0, ipaPath);
            [[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
            if (ret == 0)   {
                NSLog(@"VAPIHelper: InstallIPA installed successfully!");
                return YES;
            } else {
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
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSArray *deviceInfo = @[[NSString stringWithUTF8String:machine], [[UIDevice currentDevice] systemVersion]];
    VAPIDeviceString = [deviceInfo componentsJoinedByString:@"/"];
    NSLog(@"VAPIHelper: VAPIDeviceString = %@", VAPIDeviceString);
    free(machine);
    return VAPIDeviceString;
}

@end

