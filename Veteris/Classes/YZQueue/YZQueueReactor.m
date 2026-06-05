#import "YZQueueReactor.h"
#import "YZQueueState.h"
#import "../../Clutch/ApplicationLister.h"
#import "../../AppDelegate.h"
#import <AppSupport/CPDistributedMessagingCenter.h>

@implementation YZQueueReactor {
    NSNotificationCenter *_notificationCenter;
    YZQueueState *_state;
    NSMutableArray *_systemInstalledApps;
    dispatch_queue_t _queue;
    CPDistributedMessagingCenter *_distributedMessageCenter;
}

+ (YZQueueReactor *)sharedInstance {
    static YZQueueReactor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YZQueueReactor alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self start];
    }
    return self;
}

- (void)start {
    _systemInstalledApps = [NSMutableArray new];
    _queue = dispatch_queue_create("moe.yzu.Veteris.queue.reactor", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(_queue, ^{
        _notificationCenter = [NSNotificationCenter defaultCenter];
        [_notificationCenter addObserver:self selector:@selector(handleNotification:) name:@"YZQueueRepStateChange" object:nil];
        _distributedMessageCenter = [CPDistributedMessagingCenter centerNamed:@"moe.yzu.Veteris"];
        _state = [[YZQueueState alloc] init];
        [self refreshInstalledApps];
    });
}

- (void)handleNotification:(NSNotification *)notification {
    YZQueueRep *rep = notification.object;
    if (rep == nil) {
        return;
    }
    if (rep.state == YZRepStateInstalled) {
        if ([_systemInstalledApps containsObject:rep.bundleID]) {
            return;
        }
        [self markNewlyInstalled:rep.bundleID];
        [_systemInstalledApps addObject:rep.bundleID];
    }
}

- (void)refreshInstalledApps {
    for (NSString *key in [[[ApplicationLister sharedInstance] installedApps] allKeys]) {
        if (![_systemInstalledApps containsObject:key]) {
            [_systemInstalledApps addObject:key];
        }
    }
}

- (void)markNewlyInstalled:(NSString *)bundleId {
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        return;
    }
    [_distributedMessageCenter sendMessageName:@"moe.yzu.Veteris.MarkNewlyInstalled" userInfo:@{@"bundleIdentifier": bundleId}];
}

- (void)launchApp:(NSString *)bundleId {
    debugLog(@"Launching app: %@", bundleId);
    [_distributedMessageCenter sendMessageName:@"moe.yzu.Veteris.LaunchApp" userInfo:@{@"bundleIdentifier": bundleId}];
}

@end