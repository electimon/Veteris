//
//  ApplicationLister.h
//  Hand Brake
//
//  Created by Zorro
//
//  Re-tailored for use in Clutch

#import "Application.h"

@interface ApplicationLister : NSObject

+ (instancetype)sharedInstance;

- (NSDictionary *)installedApps;
- (NSArray *)crackableApps;
- (NSArray *)crackedApps;
- (NSArray *)modifiedApps;
- (void)crackedApp:(ApplicationC *)app;
@end