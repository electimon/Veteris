//
//  AppDelegate.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "AppDelegate.h"
#import "Classes/VAPIHelper.h"
#import "KeychainItemWrapper.h"
#include <sys/sysctl.h>

@implementation AppDelegate
@synthesize VAPIDeviceString;
@synthesize installingBool;
@synthesize downloadingBool;
@synthesize sessionToken;
@synthesize defaults;
@synthesize apiRootURL;
@synthesize apiStaticURL;
@synthesize apiBaseURL;
@synthesize _VAPIHelper;
@synthesize navigationController;
@synthesize debugOn;
@synthesize imageCache;
@synthesize keychain;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.VAPIDeviceString = [VAPIHelper setVAPIDeviceString];
    defaults = [NSUserDefaults standardUserDefaults];
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"VeterisLoginData" accessGroup:nil];
    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionaryWithObject:API_ROOT_URL forKey:@"server_url_preference"];
    [appDefaults setValue:[NSNumber numberWithBool:NO] forKey:@"debug_on"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    _VAPIHelper = [VAPIHelper new];
    self.apiBaseURL = [NSString stringWithFormat:@"%@/", [defaults stringForKey:@"server_url_preference"]];
    self.apiRootURL = [NSString stringWithFormat:@"%@%@", self.apiBaseURL, @"1.1/"];
    self.apiStaticURL = [NSString stringWithFormat:@"%@%@", self.apiBaseURL, @"/static/"];
    self.installingBool = false;
    self.downloadingBool = false;
    // Should enable debugging when connected to debugger
    self.debugOn = [self isDebuggerAttached] ? [NSNumber numberWithBool:YES] : [defaults valueForKey:@"debug_on"];
    self.debugOn = [NSNumber numberWithBool:YES];
    self.imageCache = [NSCache new];
    //NSString *token = [[NSString alloc] initWithData:[keychain objectForKey:CFBridgingRelease(kSecValueData)] encoding:NSUTF8StringEncoding];
    NSString *token = [defaults valueForKey:@"token"];
    if (!([token length] == 0)) {
        self.authTokenPresent = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (![VAPIHelper checkTokenValidity]) {
                self.authTokenPresent = NO;
                [VAPIHelper debugLog:@"AppDelegate" message:@"Token invalid, deleting"];
                [defaults removeObjectForKey:@"token"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logged Out" message:@"Your account no longer exists, please re-register." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alertView show];
                });
            } else {
                [VAPIHelper debugLog:@"AppDelegate" message:@"Token valid"];
            }
        });
    } else {
        self.authTokenPresent = NO;
    }
    [VAPIHelper debugLog:@"AppDelegate" message:[NSString stringWithFormat:@"authTokenPresent is %@", self.authTokenPresent ? @"YES" : @"NO"]];
    [VAPIHelper debugLog:@"AppDelegate" message:[NSString stringWithFormat:@"X-Veteris-Device is %@", self.VAPIDeviceString]];
    [VAPIHelper debugLog:@"AppDelegate" message:[NSString stringWithFormat:@"apiRootURL is %@", self.apiRootURL]];
    //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:195 green:177 blue:225 alpha:255]];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *updateVersion = [VAPIHelper checkForUpdates];
        if (updateVersion){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Available!" message:[NSString stringWithFormat:@"New version %@ is available! Update now?", updateVersion] delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Ok", nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alertView show];
            });
        }
    });
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *bundleid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *urlStr = [NSString stringWithFormat:@"cydia://package/%@", bundleid];
        NSURL *url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];
    }
}

// Analytical utilities

+ (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

/**
 * Check if the debugger is attached
 *
 * Taken from https://github.com/plausiblelabs/plcrashreporter/blob/2dd862ce049e6f43feb355308dfc710f3af54c4d/Source/Crash%20Demo/main.m#L96
 *
 * @return `YES` if the debugger is attached to the current process, `NO` otherwise
 */
- (BOOL)isDebuggerAttached {
    static BOOL debuggerIsAttached = NO;
    
    static dispatch_once_t debuggerPredicate;
    dispatch_once(&debuggerPredicate, ^{
        struct kinfo_proc info;
        size_t info_size = sizeof(info);
        int name[4];
        
        name[0] = CTL_KERN;
        name[1] = KERN_PROC;
        name[2] = KERN_PROC_PID;
        name[3] = getpid(); // from unistd.h, included by Foundation
        
        if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
            NSLog(@"[HockeySDK] ERROR: Checking for a running debugger via sysctl() failed: %s", strerror(errno));
            debuggerIsAttached = false;
        }
        
        if (!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0)
            debuggerIsAttached = true;
    });
    
    return debuggerIsAttached;
}
@end
