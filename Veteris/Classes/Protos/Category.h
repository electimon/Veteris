#import "../../Protos/Categories.pb.h"

@interface CategoryProt : NSObject
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
- (CategoryProt *)initFromCategoryProto:(CategoryMsg)proto;
@end