#import <sys/ioctl.h>
#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#define NSPrint(M, ...) fprintf(stderr, "%s \n", [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);

#define CLUTCH_DEBUG 1

#ifdef CLUTCH_DEBUG
#   define FILE_NAME (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__) // shortened path of __FILE__ is there is one
#
#   define NSLog(M, ...) NSLog(@"\033[0;32mDEBUG\033[0m | %s:%d | %s\n", FILE_NAME, __LINE__, [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);
#   define DEBUG(M, ...) NSLog(@"\033[0;32mDEBUG\033[0m | %s:%d | %s\n", FILE_NAME, __LINE__, [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);
#   define ERROR(M, ...) fprintf(stderr, "\033[0;32mERROR\033[0m | %s \n", [[NSString stringWithFormat:M, ##__VA_ARGS__] UTF8String]);

#   define FILE_NAME (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__) // shortened path of __FILE__ is there is one

#else
#   define DEBUG(M, ...)
#   define NSLog(M, ...)
#   define ERROR(M, ...)
#endif