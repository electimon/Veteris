#import "YZQueueState.h"
#import "YZQueueManager.h"
#import "YZQueueReactor.h"
#import "../VAPIHelper/VAPIHelper.h"

// Since the queue is basically a living thing, mutability is dangerous, this class is for accessing the state of the queue in a immutable way.
// basically we just copy the current state and this class utilizes that copy.

@implementation YZQueueState {
    NSArray *_reps;
}

- (NSArray *)reps {
    if (!_reps) {
        [self refreshReps];
    }
    return _reps;
}

- (void)refreshReps {
    _reps = [YZQueueManager allReps];
}

- (NSUInteger)total {
    debugLog(@"Total reps: %lu", (unsigned long)[self reps].count);
    return _reps.count;
}

- (NSUInteger)totalWithState:(YZRepState)state {
    NSUInteger count = 0;
    for (YZQueueRep *rep in [self reps]) {
        if (rep.state == state) {
            count++;
        }
    }
    debugLog(@"Total reps with state %d: %lu", state, (unsigned long)count);
    return count;
}

- (YZQueueRep *)repForSection:(NSUInteger)section atIndex:(NSUInteger)index {
    NSUInteger count = 0;
    for (YZQueueRep *rep in [self reps]) {
        if (rep.state == section) {
            if (count == index) {
                return rep;
            }
            count++;
        }
    }
    return nil;
}

- (bool)markRepAsCancelled:(YZQueueRep*)rep {
    return [YZQueueManager markRepAsCancelled:rep];
}

- (bool)retryRep:(YZQueueRep*)rep {
    return [YZQueueManager retryRep:rep];
}

- (void)launchApp:(NSString *)bundleId {
    [[YZQueueReactor sharedInstance] launchApp:bundleId];
}

- (void)attachProgressBlock:(void (^)(NSUInteger current, NSUInteger total))block toRep:(YZQueueRep *)rep {
    debugLog(@"Attaching progress block to rep: %@", rep.bundleID);
    [YZQueueManager attachProgressBlock:block toRep:rep];
}
@end
