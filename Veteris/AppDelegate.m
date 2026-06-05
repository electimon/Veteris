//
//  AppDelegate.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "AppDelegate.h"
#include <sys/sysctl.h>
#import "Classes/VAPIHelper/VAPIHelper.h"
#import "Classes/QueueTableViewController/QueueTableViewController.h"
#import "Clutch/ZipArchive.h"
#import "TargetConditionals.h"
#import <QuartzCore/QuartzCore.h>
#import <xpc/xpc.h>
#import "Classes/YZApplication/YZApplication.h"
#import "RRFPSBar/RRFPSBar.h"
#import "Classes/YZQueue/YZQueueManager.h"
#import <KSCrash.h>
#import <KSCrashInstallation.h>
#import "Classes/VAPIHelper/KSCrashInstallationVAPI.h"
#import "Classes/DebugTextView/DebugTextView.h"

@implementation AppDelegate
@synthesize themeManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationBar *moreNaviBar = [((UITabBarController *)self.window.rootViewController) moreNavigationController].navigationBar;
    [moreNaviBar setBarStyle:UIBarStyleBlack];
    [moreNaviBar setTranslucent:false];

    UINavigationController *queuedNaviController = [[UINavigationController alloc] initWithRootViewController:[[QueueTableViewController alloc] init]];
    queuedNaviController.navigationBar.barStyle = UIBarStyleBlack;
    queuedNaviController.tabBarItem.title = NSLocalizedString(@"Queue", @"Queue");
    queuedNaviController.tabBarItem.image = [UIImage imageNamed:@"QueueTableIcon"];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:((UITabBarController *)self.window.rootViewController).viewControllers];
    [viewControllers addObject:queuedNaviController];
    [((UITabBarController *)self.window.rootViewController) setViewControllers:viewControllers];

#ifdef DEBUG
    [DebugTextView attachToWindow:self.window];
//#endif
    [self becomeFirstResponder];
    //[[RRFPSBar sharedInstance] setHidden:NO];
#endif
    // UI Changes
    UIImage *backgroundImage = [UIImage imageNamed:@"UITabBarBG"];
    [[UITabBar appearance] setBackgroundImage:backgroundImage];
    [UINavigationBar.appearance setBackgroundImage:[UIImage imageNamed:@"UITitleBarBG"] forBarMetrics:UIBarMetricsDefault];
    ((UITabBarController *)self.window.rootViewController).customizableViewControllers = [NSArray arrayWithObjects:nil, nil];
    [((UITabBarController *)self.window.rootViewController) moreNavigationController].delegate = self;
    themeManager = [ThemeManager sharedInstance];
    [themeManager applyTintToTabBars];
    [themeManager applyTintToNavigationBars];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController *categoriesNaviController = [((UITabBarController *)self.window.rootViewController).viewControllers objectAtIndex:2];
    categoriesNaviController.title = NSLocalizedString(@"Categories", @"Categories");
    UINavigationController *allAppsNaviController = [((UITabBarController *)self.window.rootViewController).viewControllers objectAtIndex:4];
    allAppsNaviController.title = NSLocalizedString(@"AllApps", @"AllApps");
    UINavigationController *crackNaviController = [((UITabBarController *)self.window.rootViewController).viewControllers objectAtIndex:5];
    crackNaviController.title = NSLocalizedString(@"Crack", @"Crack");
    UINavigationController *featuredNaviController = [((UITabBarController *)self.window.rootViewController).viewControllers objectAtIndex:1];
    featuredNaviController.title = NSLocalizedString(@"Featured", @"Featured");
    // Register for crash handling
#ifdef DEBUG
    NSSetUncaughtExceptionHandler(&myExceptionHandler);
#endif
    if (![launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        // safe to delete sandbox
        debugLog(@"Emptying sandbox");
        [self emptySandbox];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self cleanDownloadDirectory];
        [self installCrashHandler];
    });
    return YES;
}

- (void)cleanDownloadDirectory {
    NSString *downloadDir = downloadPath();
    NSFileManager *manager = [[NSFileManager alloc] init];
    if (![manager fileExistsAtPath:downloadDir]) {
        NSError *createDirError = nil;
        if (![manager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:&createDirError]) {
            debugLog(@"Failed to create download directory: %@, error: %@", downloadDir, createDirError.localizedDescription);
            return;
        } else {
            debugLog(@"Created download directory: %@", downloadDir);
        }
    }
    NSDirectoryEnumerator *fileEnumerator = [manager enumeratorAtPath:downloadDir];
    for (NSString *filename in fileEnumerator) {
        NSString *filePath = [downloadDir stringByAppendingPathComponent:filename];
        NSError *error = nil;
        NSDictionary *attributes = [manager attributesOfItemAtPath:filePath error:&error];
        if (!attributes) {
            debugLog(@"Failed to get attributes for file: %@, error: %@", filename, error.localizedDescription);
            continue;
        }
        if ([[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeRegular]) {
            if (![manager removeItemAtPath:filePath error:&error]) {
                debugLog(@"Failed to delete file: %@, error: %@", filename, error.localizedDescription);
            } else {
                debugLog(@"Deleted file: %@", filename);
            }
        }
    }
}

#ifdef DEBUG
void myExceptionHandler(NSException *exception)
{
    debugLog(@"CRASH: %@", exception);
    debugLog(@"Stack Trace: %@", [exception callStackSymbols]);
}
#endif
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // We only handle .ipa files for now
    ((UITabBarController *)self.window.rootViewController).selectedIndex = 6;
    if ([[url pathExtension] isEqualToString:@"ipa"]) {
        debugLog(@"Opening IPA file: %@", [url path]);
        YZApplication *app = [YZApplication open:[url path]];
        if (app == nil) {
            debugLog(@"Failed to open IPA file");
            return NO;
        }
        debugLog(@"App container created");
        [YZQueueManager enqueueYZApplicationDownloaded:app];
        return YES;
    }
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [VAPIHelper checkForUpdates];
}

-(void)emptySandbox {
    NSString *rootPath = @"/var/mobile/Library/Application Support/Containers/com.ixmoe.1pwn.Veteris/Documents/Inbox";
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *fileEnumerator = [manager enumeratorAtPath:rootPath];

    for (NSString *filename in fileEnumerator) {
        debugLog(@"filename = %@", filename);
        NSString *filePath = [rootPath stringByAppendingPathComponent:filename];
        
        NSError *error = nil;
        if (![manager removeItemAtPath:filePath error:&error]) {
            debugLog(@"Failed to delete file: %@, error: %@", filename, error.localizedDescription);
        } else {
            debugLog(@"Deleted file: %@", filename);
        }
    }
    
    debugLog(@"Sandbox has been emptied.");
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *bundleid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *urlStr = [NSString stringWithFormat:@"cydia://package/%@", bundleid];
        NSURL *url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *) viewController animated:(BOOL)animated {
    if (viewController == [navigationController.viewControllers objectAtIndex:0]) {
        [themeManager applyThemeToNavigationBar:navigationController.navigationBar];
        ((UITabBarController *)self.window.rootViewController).customizableViewControllers = [NSArray arrayWithObjects:nil, nil];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#ifdef DEBUG
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(event.type == UIEventSubtypeMotionShake)
    {
        [[DebugTextView fromWindow:self.window] toggle];
    }
}
#endif

- (void) installCrashHandler
{
    KSCrashInstallation* installation = [KSCrashInstallationVAPI sharedInstance];
    // Install the crash handler. This should be done as early as possible.
    // This will record any crashes that occur, but it doesn't automatically send them.
    [installation install];
    // Send all outstanding reports. You can do this any time; it doesn't need
    // to happen right as the app launches. Advanced-Example shows how to defer
    // displaying the main view controller until crash reporting completes.
    [installation sendAllReportsWithCompletion:^(NSArray* reports, BOOL completed, NSError* error)
     {
         if(completed)
         {
             debugLog(@"Sent %d reports", (int)[reports count]);
         }
         else
         {
             debugLog(@"Failed to send reports: %@", error);
         }
     }];
}
@end
