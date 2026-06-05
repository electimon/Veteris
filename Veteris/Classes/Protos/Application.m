#include "Application.h"
#import "../VAPIHelper/VAPIHelper.h"
#import "../../AppDelegate.h"

@implementation Application // This class is only used in instances where app icon is usually wanted, so even
// though its bad design to update delegate cache in the geticon method, we do it anyway because im the santa claus of this codebase

- (Application *)initFromAppProto:(AppMsg)app {
    self = [super init];
    if (self) {
        self.versions = (__bridge NSMutableArray *)app.versions.arg;
        self.name = [NSString stringWithUTF8String:app.name.arg];
        self.developer = [NSString stringWithUTF8String:app.developer.arg];
        self.bundleid = [NSString stringWithUTF8String:app.bundleid.arg];
        self.iconurl = [NSString stringWithUTF8String:app.iconurl.arg];
        self.app_description = [NSString stringWithUTF8String:app.description.arg];
        self.nilIcon = NO;
        self.isVTableEntry = NO;
    }
    return self;
}

- (Application *)initFromVTableEntryProto:(VTableEntryMsg)entry {
    self = [super init];
    if (self) {
        self.name = [NSString stringWithUTF8String:entry.name.arg];
        self.bundleid = [NSString stringWithUTF8String:entry.bundleid.arg];
        self.developer = [NSString stringWithUTF8String:entry.developer.arg];
        self.iconurl = [NSString stringWithUTF8String:entry.iconurl.arg];
        self.version = [NSString stringWithUTF8String:entry.version.arg];
        self.nilIcon = NO;
        self.isVTableEntry = YES;
    }
    return self;
}

- (void)doGetIcon {
    [VAPISS getStatic:self.iconurl completion:^(NSData *data, NSError *error){
        if (error == nil) {
            self.icon = [UIImage imageWithData:data];
            if (self.icon == nil) {
                debugLog(@"Failed to load image for %@, bundleid: %@, app image url: %@", self.name, self.bundleid, self.iconurl);
                self.nilIcon = YES;
            }
        }
    }];
}
@end