#import "LoadingIndicatorView.h"
#import "AppDelegate.h"

@implementation LoadingIndicatorView {
    UIActivityIndicatorView *activityIndicator;
    UILabel *textView;
}
+ (LoadingIndicatorView*)attachToView:(UIView *)view {
    LoadingIndicatorView *loadingView = [[LoadingIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [loadingView constructWithCenter:view.center];
    [view addSubview:loadingView];
    return loadingView;
}

- (void)constructWithCenter:(CGPoint)center {
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    textView = [[UILabel alloc] initWithFrame:CGRectMake(activityIndicator.frame.origin.x + activityIndicator.frame.size.width + 8, 0, 0, 0)];
    textView.text = NSLocalizedString(@"Loading", "loading text");
    [textView sizeToFit];
    textView.textColor = [UIColor grayColor];
    textView.backgroundColor = [UIColor clearColor];
    textView.textAlignment = NSTextAlignmentLeft;
    float width = textView.frame.size.width + activityIndicator.frame.size.width;
    float height = MAX(textView.frame.size.height, activityIndicator.frame.size.height);
    self.frame = CGRectMake(0, 0, width, height);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:activityIndicator];
    [self addSubview:textView];
    UITabBarController *tabBarController = (UITabBarController *)getDelegate().window.rootViewController;
    UINavigationController *naviController = (UINavigationController *)tabBarController.selectedViewController;
    debugLog(@"navi height: %f", naviController.navigationBar.frame.size.height);
    self.center = CGPointMake(center.x, center.y);
    debugLog(@"center.y: %f", self.center.y);
    [activityIndicator startAnimating];
}

- (void)destroy {
    [activityIndicator stopAnimating];
    [self removeFromSuperview];
    activityIndicator = nil;
    textView = nil;
}
@end