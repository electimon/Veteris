//
//  Application.h
//  Hand Brake
//
//  Created by Ninja on 28/02/2013.
//  Copyright (c) 2013 Hackulous. All rights reserved.
//
//  Improved by Zorro :P
//
//  Re-tailored for use in Clutch

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include "out.h"

@class ApplicationC;
@protocol ApplicationDelegate<NSObject>

- (void)crackingProcessStarted:(ApplicationC *)app;
- (void)application:(ApplicationC *)app crackingProcessStatusChanged:(NSString *)status progress:(float)progress;
- (void)crackingProcessFinished:(ApplicationC *)app;

@end

@interface ApplicationC : NSObject {
   @public
    BOOL isCracking;
    BOOL finishedSuccessfully;
    NSDictionary *progress;
    NSDictionary *_info;
}

- (instancetype)initWithAppInfo:(NSDictionary *)info;

- (NSString *)appDirectory;
- (NSString *)applicationContainer;
- (NSString *)applicationDirectory;
- (NSString *)applicationBundleID;
- (NSString *)applicationDisplayName;
- (NSString *)applicationExecutableName;
- (NSString *)applicationName;
- (NSString *)realUniqueID;
- (NSString *)applicationVersion;
- (NSString *)minimumOSVersion;
- (UIImage *)applicationIcon;
- (NSData *)applicationSINF;
- (NSInteger)appVersion;

- (NSDictionary *)dictionaryRepresentation;

@end
