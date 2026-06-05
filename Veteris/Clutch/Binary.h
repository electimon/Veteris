#import <Foundation/Foundation.h>
#import "Preferences.h"
#import "out.h"

#include <mach-o/arch.h>
#include <mach-o/dyld.h>
#include <mach-o/fat.h>
#include <mach-o/loader.h>


@interface Binary : NSObject {
   @public
    BOOL overdriveEnabled;
}

- (id)initWithBinary:(NSString *)path;
- (BOOL)crackBinaryToFile:(NSString *)path error:(NSError **)error;

@end
