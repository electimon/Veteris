#import "NSString+Ext.h"
#import "../../md5/md5.h"

@implementation NSString (Ext)

- (NSString *)MD5Hash
{
	if ([self length])
	{
		MD5_CTX ctx;
		unsigned char digest[16];
		
		MD5Init(&ctx);
		
		MD5Update(&ctx, (unsigned char *)[self UTF8String], [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
		
		MD5Final(digest, &ctx);
		
		char hexdigest[33];
		int a;
		
		for (a = 0; a < 16; a++) sprintf(hexdigest + 2*a, "%02x", digest[a]);
		
		return [NSString stringWithUTF8String:hexdigest];
	}
	else
		return nil;
}
@end