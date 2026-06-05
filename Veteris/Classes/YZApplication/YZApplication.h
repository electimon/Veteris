#import "YZZipArchive.h"
#import "../Protos/Application.h"
#import "../Protos/Version.h"

@interface YZApplication : NSObject
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *bundleID;
@property (strong, nonatomic) NSString *developer;
@property (strong, nonatomic) NSString *minimumOS;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *iconurl;
- (YZApplication *)initFromApp:(Application *)app version:(Version *)version;
+ (YZApplication *)open:(NSString *)path;
- (void)setPath:(NSString *)path;
@end