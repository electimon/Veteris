//
//  Cracker.h
//  Clutch
//
//  Created by DilDog on 12/22/13.
//
//

#import <Foundation/Foundation.h>
#import "Application.h"
#import "Binary.h"

@interface Cracker : NSObject {
   @public
    NSString *_tempPath;
    NSString *_tempBinaryPath;
    NSString *_binaryPath;
    Binary *_binary;
    ApplicationC *_app;
    NSString *_workingDir;
    NSString *_ipapath;
}

- (id)init;
- (BOOL)prepareFromInstalledApp:(ApplicationC *)app;
- (BOOL)execute;
- (NSString *)generateIPAPath;

@end