#import "Suggestion.h"

@implementation Suggestion
- (Suggestion *)initFromSuggestionProto:(SuggestionMsg)proto {
    self = [super init];
    if (self) {
        self.name = [NSString stringWithUTF8String:proto.name.arg];
        self.bundleid = [NSString stringWithUTF8String:proto.bundleid.arg];
    }
    return self;
}
@end
