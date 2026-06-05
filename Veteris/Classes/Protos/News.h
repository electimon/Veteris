#import "../../Protos/News.pb.h"

@interface NewsPost : NSObject
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *link;
- (NewsPost *)initFromNewsEntryProto:(NewsEntry)proto;
@end
