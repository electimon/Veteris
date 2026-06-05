#import "YZAlert.h"
#import "../YZLog/YZLog.h"

static NSString   *s_multiPartTitle = nil;
static NSArray    *s_multiPartMessages = nil;
static NSString   *s_multiPartSeparator = nil;
static NSInteger  s_multiPartCurrentIndex = -1;
static BOOL       s_isMultiPartAlertActive = NO;
static NSUInteger s_activeAlertTypeBitmask = 0;

@implementation YZAlert

+ (void)alert:(NSString *)title message:(NSString *)message separator:(NSString *)separator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (s_isMultiPartAlertActive) {
            debugLog(@"YZAlert: Ignoring new multi-part alert because one is already active.");
            return;
        }
        
        if (!message || !separator || separator.length == 0) {
             debugLog(@"YZAlert: Message or separator invalid for multi-part alert.");
             s_multiPartMessages = @[(message ?: @"")];
        } else {
             s_multiPartMessages = [message componentsSeparatedByString:separator];
        }

        if (s_multiPartMessages.count == 0) {
            debugLog(@"YZAlert: No message parts to show.");
            return;
        }
        s_multiPartTitle = [title copy];
        s_multiPartCurrentIndex = 0;
        s_isMultiPartAlertActive = YES;
        // s_multiPartSeparator = [separator copy]; // Only store if needed later

        debugLog(@"Starting multi-part alert. Title: '%@', Parts: %lu", s_multiPartTitle, (unsigned long)s_multiPartMessages.count);
        [self showMultiPartAlert];
    });
}

+ (void)alert:(NSString *)title message:(NSString *)message type:(VAPIHelperError)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
             if ((s_activeAlertTypeBitmask & type) == type) {
                 debugLog(@"YZAlert: Alert type %lu already showing, skipping.", (unsigned long)type);
                 return;
             }
             s_activeAlertTypeBitmask |= type;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        alertView.tag = type;
        [alertView show];
         debugLog(@"Showing typed alert. Title: '%@', Type/Tag: %ld", title, (long)alertView.tag);
    });
}

+ (void)showMultiPartAlert {
    if (!s_isMultiPartAlertActive || s_multiPartCurrentIndex < 0 || s_multiPartCurrentIndex >= s_multiPartMessages.count) {
        debugLog(@"YZAlert: Invalid state for showing multi-part alert. Cleaning up.");
        [self resetMultiPartState]; 
        return;
    }

    NSString *msg = [s_multiPartMessages objectAtIndex:s_multiPartCurrentIndex];
    NSString *buttonTitle;

    if (s_multiPartCurrentIndex == s_multiPartMessages.count - 1) {
        buttonTitle = NSLocalizedString(@"Done", nil);
    } else {
        buttonTitle = NSLocalizedString(@"Next", nil);
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:s_multiPartTitle
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:buttonTitle, nil];
    alertView.tag = 0;
    [alertView show];
    debugLog(@"Showing multi-part alert part %ld/%lu. Title: '%@'", (long)s_multiPartCurrentIndex + 1, (unsigned long)s_multiPartMessages.count, s_multiPartTitle);
}

+ (void)resetMultiPartState {
    debugLog(@"Resetting multi-part alert state.");
    s_multiPartTitle = nil;
    s_multiPartMessages = nil;
    // s_multiPartSeparator = nil;
    s_multiPartCurrentIndex = -1;
    s_isMultiPartAlertActive = NO;
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    dispatch_async(dispatch_get_main_queue(), ^{
        debugLog(@"Delegate received click for alert with tag: %ld, button index: %ld", (long)alertView.tag, (long)buttonIndex);

        if (alertView.tag == 0) {
            if (!s_isMultiPartAlertActive) {
                 debugLog(@"YZAlert: Received callback for multi-part alert, but state indicates inactive. Ignoring.");
                 return;
            }

            if (buttonIndex == 1) {
                s_multiPartCurrentIndex++;
                if (s_multiPartCurrentIndex < s_multiPartMessages.count) {
                    [self showMultiPartAlert];
                } else {
                     debugLog(@"Multi-part alert sequence completed.");
                    [self resetMultiPartState];
                }
            } else {
                 debugLog(@"Multi-part alert sequence closed.");
                [self resetMultiPartState];
            }

        } else {
            VAPIHelperError type = alertView.tag;
            @synchronized(self) {
                if ((s_activeAlertTypeBitmask & type) == type) {
                     s_activeAlertTypeBitmask &= ~type;
                }
            }
        }
    });
}

+ (void)alertViewCancel:(UIAlertView *)alertView {
     dispatch_async(dispatch_get_main_queue(), ^{
         debugLog(@"Delegate received CANCEL for alert with tag: %ld", (long)alertView.tag);
         if (alertView.tag == 0) {
             if (s_isMultiPartAlertActive) {
                 debugLog(@"Multi-part alert sequence cancelled.");
                 [self resetMultiPartState];
             }
         } else {
            VAPIHelperError type = alertView.tag;
             @synchronized(self) {
                 if ((s_activeAlertTypeBitmask & type) == type) {
                      s_activeAlertTypeBitmask &= ~type;
                 }
            }
         }
     });
}

@end