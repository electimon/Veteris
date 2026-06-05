//
//  AppDelegate.h
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Classes/VAPIHelper.h"
#import "KeychainItemWrapper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *VAPIDeviceString;
@property (strong, nonatomic) NSString *sessionToken;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSString *apiRootURL;
@property (strong, nonatomic) NSString *apiStaticURL;
@property (strong, nonatomic) NSString *apiBaseURL;
@property (strong, nonatomic) VAPIHelper *_VAPIHelper;
@property (strong, nonatomic) UINavigationController *navigationController;
@property BOOL downloadingBool;
@property BOOL installingBool;
@property (strong, nonatomic) NSNumber *debugOn;
@property (strong, nonatomic) NSCache *imageCache;
@property BOOL authTokenPresent;
@property (strong, nonatomic) KeychainItemWrapper *keychain;
+ (NSString *) getSysInfoByName:(char *)typeSpecifier;
@end
