#import "../../Protos/Suggestions.pb.h"

@interface Suggestion : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bundleid;
- (Suggestion *)initFromSuggestionProto:(SuggestionMsg)proto;
@end