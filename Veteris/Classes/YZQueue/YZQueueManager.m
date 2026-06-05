#import "YZQueueManager.h"
#import "YZQueueReactor.h"
#import "../VAPIHelper/VAPIHelper.h"
#import "../../BBHTTP/BBHTTP.h"

@implementation YZQueueManager {
    dispatch_queue_t _installQueue;
    dispatch_queue_t _queue;
    NSNotificationCenter *_nc;
    NSMutableSet *_reps;
    NSObject *_repsLock;
    YZQueueReactor *_reactor;
}

struct StateContext {
    YZRepState state;
    NSUInteger *count;
};

#pragma - mark Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self start];
    }
    return self;
}

+ (YZQueueManager *)sharedInstance {
    static YZQueueManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YZQueueManager alloc] init];
        BBHTTPExecutor *executor = [BBHTTPExecutor sharedExecutor];
        executor.maxParallelRequests = 3;
    });
    return sharedInstance;
}

- (void)start {
    _installQueue = dispatch_queue_create("moe.yzu.Veteris.queue.install", DISPATCH_QUEUE_SERIAL);
    _queue = dispatch_queue_create("moe.yzu.Veteris.queue.main", DISPATCH_QUEUE_CONCURRENT);
    _nc = [NSNotificationCenter defaultCenter];
    [_nc addObserver:self selector:@selector(handleNotification:) name:@"YZQueueRepStateChange" object:nil];
    _reps = [NSMutableSet new];
    _repsLock = [[NSObject alloc] init];
    _reactor = [[YZQueueReactor alloc] init];
    debugLog(@"YZQueueManager started");
        // Application *app = [[Application alloc] init];
        // app.app_description = @"This is a description";
        // app.developer = @"Developer";
        // app.name = @"App Name";
        // app.bundleid = @"com.example.app";
        // app.icon = [UIImage imageNamed:@"icon.png"];
        // Version *version = [[Version alloc] init];
        // version.version = @"1.0";
        // YZApplication *app2 = [[YZApplication alloc] initFromApp:app version:version];

        // [YZQueueRep detachRepWithYZApp:app2 andURL:nil];
}

#pragma - mark Queue Operations
+ (void)enqueueYZApplicationForDownload:(YZApplication *)yzApp {
    dispatch_async([YZQueueManager sharedInstance]->_queue, ^{
        [YZQueueRep detachRepWithYZApp:yzApp andURL:[NSString stringWithFormat:@"%@static/%@", [VAPIHelper getApiStaticURL], [yzApp.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    });
}

+ (void)enqueueYZApplicationDownloaded:(YZApplication *)yzApp {
    dispatch_async([YZQueueManager sharedInstance]->_queue, ^{
        [YZQueueRep detachRepWithYZApp:yzApp andURL:nil];
    });
}

- (void)enqueueAppContainerForInstall:(YZQueueRep *)appRep {
    dispatch_async(_installQueue, ^{
        appRep.state = YZRepStateInstalling;
        bool ret = [YZQueueOps installIPA:appRep.path];
        if (!ret) {
            appRep.state = YZRepStateFailed;
            return;
        }
        appRep.state = YZRepStateInstalled;
    });
}

#pragma - mark Notification Handling

- (void)handleNotification:(NSNotification *)notification {
    YZQueueRep __block *rep = notification.object;
    if (rep == nil) {
        return; // no rep, no party
    }
    YZRepState repState;
    @synchronized (_repsLock) {
        if (rep.invalid) { // check in the lock because before then we could be waiting
            return;
        }
        [_reps addObject:rep];
        repState = rep.state;
    }
    switch (repState) {
        case YZRepStateDownloaded:
            [self enqueueAppContainerForInstall:rep];
            break;
        case YZRepStateQueued:
            dispatch_async(_queue, ^{
                rep.downloadSelf();
            });
            break;
        default:
            break;
    }
}

#pragma - mark Misc Methods

+ (YZQueueRep *)actualRepForRep:(YZQueueRep *)rep {
    YZQueueRep *actualRep;
    @synchronized ([YZQueueManager sharedInstance]->_repsLock) {
        actualRep = [YZQM->_reps member:rep];
    }
    return actualRep;
}

+ (bool)markRepAsCancelled:(YZQueueRep *)rep {
    // no one has the live state of the rep, instead they should have a copy
    // we can match the rep by bundleId and version
    YZQueueRep *actualRep = [YZQueueManager actualRepForRep:rep];
    if (actualRep == nil) {
        return NO;
    }
    debugLog(@"Cancelling %@", actualRep.bundleID);
    BBHTTPRequest *request = actualRep.request;
    if (request != nil) {
        [request cancel];
    }
    // destroy the fucker
    @synchronized ([YZQueueManager sharedInstance]->_repsLock) {
        [YZQM->_reps removeObject:actualRep];
        rep.invalid = YES; // the original rep should be marked, the actual rep is non-existent now
    }
    [YZQueueOps notifyAppState:nil];
    return YES;
}

+ (bool)retryRep:(YZQueueRep *)rep {
    YZQueueRep *actualRep = [YZQueueManager actualRepForRep:rep];
    if (actualRep != nil) {
        actualRep.state = YZRepStateQueued;
        return YES;
    }
    return NO;
}

+ (NSArray *)allReps {
    NSArray *reps;
    @synchronized ([YZQueueManager sharedInstance]->_repsLock) {
        reps = [YZQM->_reps allObjects];
    }
    return reps;
}

+ (void)attachProgressBlock:(void (^)(NSUInteger current, NSUInteger total))block toRep:(YZQueueRep *)rep {
    YZQueueRep *actualRep = [YZQueueManager actualRepForRep:rep];
    if (actualRep != nil) {
        BBHTTPRequest *request = actualRep.request;
        if (request != nil) {
            request.downloadProgressBlock = block;
        }
    }
}

- (void)dealloc {
    [_nc removeObserver:self];
}
@end