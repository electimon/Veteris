#import <Foundation/Foundation.h>
#import "YZQueueRep.h"

@interface YZQueueOps : NSObject
+ (BOOL)installIPA:(NSString *)filePath;
+ (void)downloadFileToPath:(NSString *)urlString pathFromString:(NSString *)str parent:(YZQueueRep *)parent;
+ (void)notifyAppState:(YZQueueRep *)appRep;
@end