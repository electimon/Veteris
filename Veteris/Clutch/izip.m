#import "izip.h"

void zip(ZipArchive *archiver, NSString *folder, NSString *payloadPath, int compressionLevel) {}

void zip_original(ZipArchive *archiver, NSString *folder, NSString *binary, NSString *zip, int compressionLevel) {}

@class iZip;
@protocol iZipDelegate<NSObject>

- (void)zipOriginalComplete;
- (void)zipCrackedComplete;

@end

@implementation iZip

- (instancetype)initWithCracker:(Cracker *)cracker {
    if (self = [super init]) {
        _cracker = cracker;
        zip_cracked = false;
        zip_original = false;
        DebugLog(@"created IPAPAth %@", _cracker->_ipapath);
    }

    return self;
}

- (void)zipOriginalOld:(NSOperation *)operation withZipLocation:(NSString *)location {
    _zipTask = [[NSTask alloc] init];
    [_zipTask setLaunchPath:@"/bin/bash"];

    NSString *compressionArguments = [NSString stringWithFormat:@"-%u", _compressionLevel];
    NSString *args = [NSString stringWithFormat:@"cd %@; zip %@ -y -r -n .jpg:.JPG:.jpeg:.png:.PNG:.gif:.GIF:.Z:.gz:.zip:.zoo:.arc:.lzh:.rar:.arj:.mp3:.mp4:.m4a:.m4v:.ogg:.ogv:.avi:.flac:.aac \"%@\" Payload/* -x Payload/iTunesArtwork Payload/iTunesMetadata.plist \"Payload/Documents/*\" \"Payload/Library/*\" \"Payload/tmp/*\" \"Payload/*/%@\" \"Payload/*/SC_Info/*\" 2>&1> /dev/null", location, compressionArguments, _cracker->_ipapath, _cracker->_app.applicationExecutableName];
    NSError *err;
    if (![args writeToFile:@"/tmp/clutch-zip" atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        if (err)
            DebugLog(@"err%@", err);
        DebugLog(@"could not write shell script to file, weird!");
    }

    NSArray *argArray = [[NSArray alloc] initWithObjects:@"/tmp/clutch-zip", nil];

    [_zipTask setArguments:argArray];
    [_zipTask launch];
    [_zipTask waitUntilExit];
}

- (void)zipOriginal:(NSOperation *)operation {
    if (_archiver == nil) {
        _archiver = [[ZipArchive alloc] init];
        [_archiver CreateZipFile2:_cracker->_ipapath];
    }

    NSString *folder = _cracker->_app.applicationContainer;
    NSString *binary = _cracker->_app.applicationExecutableName;

    BOOL isDir = NO;

    NSMutableArray *subpaths = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:folder isDirectory:&isDir] && isDir) {
        NSDirectoryEnumerator *dirEnumerator = [NSFileManager.defaultManager enumeratorAtURL:[NSURL fileURLWithPath:folder]
                                                                  includingPropertiesForKeys:@[ NSURLNameKey, NSURLIsDirectoryKey ]
                                                                                     options:0
                                                                                errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                                    return YES;
                                                                                }];

        subpaths = [NSMutableArray new];

        for (NSURL *theURL in dirEnumerator) {

            NSString *fullPath = [theURL path];

            NSMutableArray *comp = [NSMutableArray arrayWithArray:[fullPath pathComponents]];

            [comp removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]];

            if (comp.count > 1) {
                if ((![[comp objectAtIndex:0] hasSuffix:@".app"]) && ([[comp objectAtIndex:1] hasSuffix:@".app"])) {
                    [comp removeObjectAtIndex:0];
                }
            }

            NSMutableString *aNewPath = [NSMutableString new];

            for (int i = 0; i < comp.count; i++) {
                [aNewPath appendFormat:@"%@%@", i == 0 ? @"" : @"/", [comp objectAtIndex:i]];
            }

            [subpaths addObject:aNewPath];

            // [aNewPath release]; // No need to release in ARC
        }
    }

    NSString *appGUID = [folder lastPathComponent];

    for (NSString *path in subpaths) {

        if ([path hasPrefix:[appGUID stringByAppendingPathComponent:@"Documents"]] || [path hasPrefix:[appGUID stringByAppendingPathComponent:@"Library"]] || [path hasPrefix:[appGUID stringByAppendingPathComponent:@"tmp"]] || ([path rangeOfString:@"SC_Info"].location != NSNotFound) || [path hasSuffix:binary]) {
            continue;
        }

        NSString *longPath = [folder stringByAppendingPathComponent:path];

        if ([fileManager fileExistsAtPath:longPath isDirectory:&isDir] && !isDir) {
            [_archiver addFileToZip:longPath newname:[NSString stringWithFormat:@"Payload/%@", path] compressionLevel:_compressionLevel];
        }
    }

    // [subpaths release]; // No need to release in ARC

    return;
}

- (void)zipCracked {
    if (_archiver == nil) {
        _archiver = [[ZipArchive alloc] init];
        [_archiver openZipFile2:_cracker->_ipapath];
    }

    int compressionLevel = 0;
    BOOL isDir = NO;

    NSArray *subpaths = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL exists = [fileManager fileExistsAtPath:_cracker->_tempPath isDirectory:&isDir];
    DebugLog(@"working dir %@", _cracker->_tempPath);
    if (exists && isDir) {
        subpaths = [fileManager subpathsAtPath:_cracker->_tempPath];
        // total = [subpaths count]; DEAD_STORE
    }

    for (NSString *path in subpaths) {
        // Only add it if it's not a directory. ZipArchive will take care of those.
        NSString *longPath = [_cracker->_tempPath stringByAppendingPathComponent:path];
        DebugLog(@"longpath %@ %@", longPath, path);

        if ([fileManager fileExistsAtPath:longPath isDirectory:&isDir] && !isDir) {
            DebugLog(@"adding file %@", longPath);
            [_archiver addFileToZip:longPath newname:path compressionLevel:compressionLevel];
        }
    }
    DebugLog(@"subpaths %@", subpaths);
    return;
}

- (void)setCompressionLevel:(int)level {
    _compressionLevel = level;
}

@end
