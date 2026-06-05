#import "Category.h"

@implementation CategoryProt
- (CategoryProt *)initFromCategoryProto:(CategoryMsg)proto {
    self = [super init];
    if (self) {
        self.name = [NSString stringWithUTF8String:proto.name.arg];
        self.id = [NSString stringWithUTF8String:proto.id.arg];
    }
    return self;
}
@end
