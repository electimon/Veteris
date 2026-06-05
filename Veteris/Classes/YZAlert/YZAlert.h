#import <Foundation/Foundation.h>

typedef enum {
    VAPIHelperErrorUnknown = 0,
    VAPIHelperErrorNetwork = 2,
    VAPIHelperWhatsNew = 4,
} VAPIHelperError;

@interface YZAlert : NSObject <UIAlertViewDelegate>
+ (void)alert:(NSString *)title message:(NSString *)message separator:(NSString *)separator;
+ (void)alert:(NSString *)title message:(NSString *)message type:(VAPIHelperError)type;
@end