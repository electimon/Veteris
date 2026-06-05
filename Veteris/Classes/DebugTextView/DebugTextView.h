#import <Foundation/Foundation.h>

@interface DebugTextView : UITextView
+ (DebugTextView *)fromWindow:(UIWindow *)window;
+ (DebugTextView *)attachToWindow:(UIWindow *)window;
- (void)detachFromWindow;
- (void)log:(NSString *)message;
- (void)clear;
- (void)show;
- (void)hide;
- (void)toggle;
@end