#import "YZZipArchive.h"
#import "zip/zip.h"
#import "../VAPIHelper/VAPIHelper.h"

@implementation YZZipArchive {
    struct zip_t *zip;
}
+ (YZZipArchive *)open:(NSString *)path {
    YZZipArchive *archive = [[YZZipArchive alloc] init];
    int err = 0;
    archive->zip = zip_openwitherror([path UTF8String], 0, 'r', &err);
    if (err != 0) {
        debugLog(@"[YZZipArchive] Failed to open archive: %s", zip_strerror(err));
        return nil;
    }
    return archive;
}

- (NSData *)readFile:(NSString *)path {
    void *buf = NULL;
    size_t bufsize = 0;
    zip_entry_open(zip, [path UTF8String]);
    {
        zip_entry_read(zip, &buf, &bufsize);
    }
    zip_entry_close(zip);
    if (buf == NULL || bufsize == 0) {
        return nil;
    }
    NSData *data = [NSData dataWithBytes:buf length:bufsize];
    free(buf);
    return data;
}

- (NSArray *)files {
    int i, n = zip_entries_total(zip);
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:n];
    for (i = 0; i < n; ++i) {
        zip_entry_openbyindex(zip, i);
        {
            const char *name = zip_entry_name(zip);
            [files addObject:[NSString stringWithUTF8String:name]];
        }
        zip_entry_close(zip);
    }
    return files;
}

- (void)close {
    if (zip != NULL) {
        zip_close(zip);
        zip = NULL; // Prevent double close or accessing invalid memory
    }
}

- (void)dealloc {
    [self close];
}
@end