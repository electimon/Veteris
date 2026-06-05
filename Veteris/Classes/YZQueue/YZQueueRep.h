#import <Foundation/Foundation.h>
#import "../YZApplication/YZApplication.h"

@class BBHTTPRequest;

typedef enum {
    YZRepStateInstalled = 0,
    YZRepStateInstalling,
    YZRepStateDownloaded,
    YZRepStateDownloading,
    YZRepStateQueued,
    YZRepStateFailed,
    YZRepStateCancelled,
} YZRepState;

@interface YZQueueRep : NSObject
+ (void)detachRepWithYZApp:(YZApplication *)yzApp andURL:(NSString *)url;
- (UIImage *)icon;
- (NSString *)iconurl;
- (NSString *)name;
- (NSString *)description;
- (NSString *)version;
- (NSString *)bundleID;
- (NSString *)developer;
- (NSString *)minimumOS;
- (NSString *)path;
- (void)setPath:(NSString *)path;
@property (nonatomic) bool invalid;
@property (nonatomic, assign) YZRepState state;
@property (nonatomic, weak) BBHTTPRequest *request;
@property (nonatomic) void (^downloadSelf)(void);
@end