#import "YZApplication.h"
#import "../VAPIHelper/VAPIHelper.h"
#import "../Protos/Version.h"
#import "../Protos/Application.h"

@implementation YZApplication {
    YZZipArchive *_zipArchive;
    NSString *_url;
    NSDictionary *info;
}

- (YZApplication *)initFromApp:(Application *)app version:(Version *)version {
    self = [super init];
    if (!self) {
        return nil;
    }
    self->_bundleID = app.bundleid;
    self->_name = app.name;
    self->_developer = app.developer;
    self->_iconurl = app.iconurl;
    self->_desc = @"";
    self->_icon = app.icon;
    self->_version = version.version;
    self->_url = version.fileName;
    return self;
}

+ (YZApplication *)open:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        debugLog(@"[YZApplication] File does not exist: %@", path);
        return nil;
    }
    YZApplication *app = [[YZApplication alloc] init];
    app->_zipArchive = [YZZipArchive open:path];
    bool success = [app initialize];
    if (!success) {
        debugLog(@"[YZApplication] Failed to initialize app: %@", path);
        if (app->_zipArchive != nil) {
            [app->_zipArchive close];
        }
        return nil;
    }
    app.path = path;
    debugLog(@"[YZApplication] Opened app: %@", app->_name);
    // i suppose at this point we dont need the ziparchive anymore
    [app->_zipArchive close];
    return app;
}

- (bool)initialize {
    NSArray *files = [_zipArchive files];
    if (files == nil) {
        debugLog(@"[YZApplication] No files found in archive");
        return false;
    }
    // match everything named "Info.plist"
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH %@", @"Info.plist"];
    NSArray *filtered = [files filteredArrayUsingPredicate:predicate];
    if (filtered.count == 0) {
        debugLog(@"[YZApplication] No Info.plist found in archive");
        return false;
    }
    for (NSString *file in filtered) {
        // ignore files with more than 2 slashes
        if ([[file componentsSeparatedByString:@"/"] count] > 3) {
            debugLog(@"[YZApplication] Ignoring file with more than 2 slashes: %@", file);
            continue;
        }
        // ignore files that dont end with /Info.plist
        if (![file hasSuffix:@"/Info.plist"]) {
            debugLog(@"[YZApplication] Ignoring file ending not with /Info.plist: %@", file);
            continue;
        }
        NSData *data = [_zipArchive readFile:file];
        if (data == nil) {
            debugLog(@"[YZApplication] Failed to read Info.plist: %@", file);
            continue;
        }
        NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:nil];
        if (plist == nil) {
            debugLog(@"[YZApplication] Failed to parse Info.plist: %@", file);
            continue;
        }
        _name = [plist objectForKey:@"CFBundleDisplayName"];
        if (_name == nil) {
            _name = [plist objectForKey:@"CFBundleName"];
        }
        _version = [plist objectForKey:@"CFBundleVersion"];
        _bundleID = [plist objectForKey:@"CFBundleIdentifier"];
        _developer = @"Unknown Developer";
        _minimumOS = [plist objectForKey:@"MinimumOSVersion"];
        if (_minimumOS == nil) {
            _minimumOS = @"2.0";
        }
        info = plist;
        _icon = [self findIcon];
        break;
    }
    if (_name == nil) {
        debugLog(@"[YZApplication] Failed to find app name");
        return false;
    }
    if (_version == nil) {
        debugLog(@"[YZApplication] Failed to find app version");
        return false;
    }
    if (_bundleID == nil) {
        debugLog(@"[YZApplication] Failed to find app bundle ID");
        return false;
    }
    if (_developer == nil) {
        debugLog(@"[YZApplication] Failed to find app developer");
        return false;
    }
    if (_minimumOS == nil) {
        debugLog(@"[YZApplication] Failed to find app minimum OS version");
        return false;
    }
    if (_icon == nil) {
        debugLog(@"[YZApplication] Failed to find app icon");
        return false;
    }
    return true;
}

- (UIImage *)findIcon {
    NSArray *files = [_zipArchive files];
    if (files == nil || files.count == 0) {
        debugLog(@"[YZApplication] No files found in archive");
        return nil;
    }

    // Helper block for finding a file with a given suffix
    NSData* (^findFileWithSuffix)(NSString*) = ^NSData* (NSString* suffix) {
        debugLog(@"[YZApplication] Searching for file with suffix: %@", suffix);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH %@", suffix];
        NSArray *filtered = [files filteredArrayUsingPredicate:predicate];
        if (filtered.count > 0) {
            debugLog(@"[YZApplication] Found file with suffix: %@", suffix);
            return [_zipArchive readFile:[filtered objectAtIndex:0]];
        }
        return nil;
    };

    // First, attempt to find iTunesArtwork
    NSData *data = findFileWithSuffix(@"iTunesArtwork");
    if (data != nil) {
        debugLog(@"[YZApplication] Found iTunesArtwork");
        return [UIImage imageWithData:data];
    }

    // Check for CFBundleIcons and try to find the icon files
    NSDictionary *icons = [info objectForKey:@"CFBundleIcons"];
    if (icons != nil) {
        NSDictionary *primaryIcon = [icons objectForKey:@"CFBundlePrimaryIcon"];
        if (primaryIcon != nil) {
            NSArray *iconFiles = [[[primaryIcon objectForKey:@"CFBundleIconFiles"] reverseObjectEnumerator] allObjects];
            if (iconFiles != nil && iconFiles.count > 0) {
                for (NSString *iconFile in iconFiles) {
                    NSString *iconFileCopy = iconFile;
                    if (![iconFileCopy hasSuffix:@".png"]) {
                        iconFileCopy = [iconFile stringByAppendingString:@".png"];
                    }
                    data = findFileWithSuffix(iconFileCopy);
                    if (data != nil) {
                        return [UIImage imageWithData:data];
                    }
                }
            } else {
                debugLog(@"[YZApplication] No icon files found in CFBundleIconFiles");
            }
        } else {
            debugLog(@"[YZApplication] No CFBundlePrimaryIcon found in CFBundleIcons");
        }
    } else {
        debugLog(@"[YZApplication] No CFBundleIcons found in Info.plist");
    }

    // Try default icon names
    NSArray *defaultIconNames = @[@"Icon@2x.png", @"Icon.png"];
    for (NSString *iconName in defaultIconNames) {
        data = findFileWithSuffix(iconName);
        if (data != nil) {
            return [UIImage imageWithData:data];
        }
    }

    // Finally, check CFBundleIconFile
    NSString *iconFile = [info objectForKey:@"CFBundleIconFile"];
    if (iconFile != nil) {
        if (![iconFile hasSuffix:@".png"]) {
            iconFile = [iconFile stringByAppendingString:@".png"];
        }
        data = findFileWithSuffix(iconFile);
        if (data != nil) {
            return [UIImage imageWithData:data];
        }
    }
    return nil;
}

- (void)setPath:(NSString *)path {
   _path = path;
}

- (void)dealloc {
    if (_zipArchive != nil) {
        [_zipArchive close];
    }
}
@end