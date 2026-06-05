#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#import <sys/ioctl.h>
#include <sys/types.h>
#import "../Veteris/Classes/VAPIHelper/VAPIHelper.h"

#define NSPrint(M, ...) fprintf(stderr, "%s \n", [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);

#define DebugLog(M, ...) debugLog(@"%s", [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);
#define ERROR(M, ...) debugLog(@"%s", [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);