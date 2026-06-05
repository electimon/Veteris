#import <Foundation/Foundation.h>

@interface YZQueueReactor : NSObject
+ (YZQueueReactor *)sharedInstance;
- (void)launchApp:(NSString *)bundleId;
@end