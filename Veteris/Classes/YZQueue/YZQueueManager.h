#import <Foundation/Foundation.h>
#import "YZQueueRep.h"
#import "YZQueueOps.h"

#define YZQM [YZQueueManager sharedInstance]

@interface YZQueueManager : NSObject
+ (YZQueueManager *)sharedInstance;
+ (void)enqueueYZApplicationForDownload:(YZApplication *)yzApp;
+ (void)enqueueYZApplicationDownloaded:(YZApplication *)yzApp;
+ (bool)markRepAsCancelled:(YZQueueRep *)rep;
+ (bool)retryRep:(YZQueueRep *)rep;
+ (NSArray *)allReps;
+ (void)attachProgressBlock:(void (^)(NSUInteger current, NSUInteger total))block toRep:(YZQueueRep *)rep;
@end