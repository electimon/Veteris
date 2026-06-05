@interface YZZipArchive : NSObject
+ (YZZipArchive *)open:(NSString *)path;
- (NSData *)readFile:(NSString *)path;
- (NSArray *)files;
- (void)close;
@end