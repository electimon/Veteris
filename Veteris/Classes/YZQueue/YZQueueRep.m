#import "YZQueueRep.h"
#import "YZQueueOps.h"

@implementation YZQueueRep {
    YZApplication *_app;
}

+ (void)detachRepWithYZApp:(YZApplication *)yzApp andURL:(NSString *)url {
    YZQueueRep *rep = [[YZQueueRep alloc] init];
    rep->_app = yzApp;
    rep->_invalid = NO;
    __typeof__(rep) weakSelf = rep;
    rep->_downloadSelf = ^{
        [weakSelf setState:YZRepStateDownloading];
        [YZQueueOps downloadFileToPath:url pathFromString:yzApp.bundleID parent:weakSelf];
    };
    if (url != nil) {
        rep->_app.path = url;
        [rep setState:YZRepStateQueued];
    } else {
        [rep setState:YZRepStateDownloaded];
    }
}

- (void)setState:(YZRepState)state {
    _state = state;
    [YZQueueOps notifyAppState:self];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return true;
    }
    if (![object isKindOfClass:[YZQueueRep class]]) {
        return false;
    }
    YZQueueRep *rep = (YZQueueRep *)object;
    return [rep.bundleID isEqualToString:self.bundleID] && [rep.version isEqualToString:self.version];
}

- (NSUInteger)hash {
    return [self.bundleID hash] ^ [self.version hash];
}

- (UIImage *)icon {
    return _app.icon;
}

- (NSString *)iconurl {
    return _app.iconurl;
}

- (NSString *)name {
    return _app.name;
}

- (NSString *)description {
    return _app.description;
}

- (NSString *)version {
    return _app.version;
}

- (NSString *)bundleID {
    return _app.bundleID;
}

- (NSString *)developer {
    return _app.developer;
}

- (NSString *)minimumOS {
    return _app.minimumOS;
}

- (NSString *)url {
    return _app.url;
}

- (NSString *)path {
    return _app.path;
}

- (void)setPath:(NSString *)path {
    _app.path = path;
}

@end