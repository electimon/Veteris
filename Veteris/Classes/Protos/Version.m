#import "Version.h"

@implementation Version
- (Version *)initFromVersionProto:(VersionMsg)versionProto {
    self = [super init];
    if (self) {
        self.version = [NSString stringWithUTF8String:versionProto.version.arg];
        self.fileName = [NSString stringWithUTF8String:versionProto.fileName.arg];
        self.minVersion = [NSString stringWithUTF8String:versionProto.minVersion.arg];
    }
    return self;
}
@end
