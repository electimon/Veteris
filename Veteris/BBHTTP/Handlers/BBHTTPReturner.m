#import "BBHTTPReturner.h"

@implementation BBHTTPReturner {
    void (^_block)(uint8_t* data, NSUInteger length);
}
- (instancetype)initWithBlock:(void (^)(uint8_t* data, NSUInteger length))block
{
    self = [super init];
    if (self) {
        _block = block;
    }
    return self;
}
- (NSInteger)appendResponseBytes:(uint8_t*)bytes withLength:(NSUInteger)length error:(NSError**)error {
    _block(bytes, length);
    return length;
}
@end