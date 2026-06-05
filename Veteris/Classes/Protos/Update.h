#import "../../Protos/Update.pb.h"

@interface Update : NSObject
@property (nonatomic, strong) NSString *version;
@property (nonatomic) BOOL forceUpdate;
@property (nonatomic, strong) NSString *changelog;
- (Update *)initFromUpdateProto:(UpdateMsg)updateProto;
@end