#import "Update.h"

@implementation Update
- (Update *)initFromUpdateProto:(UpdateMsg)updateProto {
    self = [super init];
    if (self) {
        self.version = [NSString stringWithUTF8String:updateProto.version.arg];
        self.forceUpdate = updateProto.force;
        self.changelog = [NSString stringWithUTF8String:updateProto.changelog.arg];
    }
    return self;
}
@end
