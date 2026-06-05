#import "DebugTextView.h"

@implementation DebugTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.textColor = [UIColor whiteColor];
        self.editable = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.userInteractionEnabled = YES;
        self.scrollEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.alpha = 0.7;
    }
    return self;
}

+ (DebugTextView *)fromWindow:(UIWindow *)window {
    for (UIView *subview in window.rootViewController.view.subviews) {
        if ([subview isKindOfClass:[DebugTextView class]]) {
            return (DebugTextView *)subview;
        }
    }
    return nil;
}

+ (DebugTextView *)attachToWindow:(UIWindow *)window {
    DebugTextView *debugView = [DebugTextView fromWindow:window];
    if (!debugView) {
        debugView = [[DebugTextView alloc] initWithFrame:CGRectMake(0, 80, window.bounds.size.width, 180)];
        debugView.tag = -69;
        [window.rootViewController.view addSubview:debugView];
    }
    return debugView;
}

- (void)detachFromWindow {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)log:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *newText = [self.text stringByAppendingFormat:@"\n%@", message];
        self.text = newText;
        [self scrollRangeToVisible:NSMakeRange(self.text.length, 0)];
    });
}

- (void)clear {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.text = @"";
    });
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = NO;
    });
}

- (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = YES;
    });
}

- (void)toggle {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = !self.hidden;
    });
}

@end
