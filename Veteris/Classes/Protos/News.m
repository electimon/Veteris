#import "News.h"

@implementation NewsPost
- (NewsPost *)initFromNewsEntryProto:(NewsEntry)proto {
    self = [super init];
    if (self) {
        self.author = [NSString stringWithUTF8String:proto.author.arg];
        self.title = [NSString stringWithUTF8String:proto.title.arg];
        self.body = [NSString stringWithUTF8String:proto.body.arg];
        self.date = [NSString stringWithUTF8String:proto.date.arg];
        if (proto.link.arg != NULL) {
            self.link = [NSString stringWithUTF8String:proto.link.arg];
        } else {
            self.link = [NSString stringWithUTF8String:""];
        }
    }
    return self;
}
@end
