#import "../../Protos/App.pb.h"

@interface Version : NSObject
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *minVersion;
- (Version *)initFromVersionProto:(VersionMsg)versionProto;
@end