#import "BBHTTPSelectiveDiscarder.h"

@interface BBHTTPReturner : BBHTTPSelectiveDiscarder
@property(copy, nonatomic) void (^contentReceviedBlock)(uint8_t* data, NSUInteger length);
- (instancetype)initWithBlock:(void (^)(uint8_t* data, NSUInteger length))block;
@end