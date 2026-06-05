#import <Foundation/Foundation.h>
#import "YZQueueRep.h"

@interface YZQueueState : NSObject
- (NSUInteger)totalWithState:(YZRepState)state;
- (NSUInteger)total;
- (YZQueueRep *)repForSection:(NSUInteger)section atIndex:(NSUInteger)index;
- (bool)markRepAsCancelled:(YZQueueRep*)rep;
- (bool)retryRep:(YZQueueRep*)rep;
- (void)refreshReps;
- (void)launchApp:(NSString *)bundleId;
- (void)attachProgressBlock:(void (^)(NSUInteger current, NSUInteger total))block toRep:(YZQueueRep *)rep;
@end