@interface LoadingIndicatorView : UIView
+ (LoadingIndicatorView*)attachToView:(UIView *)view;
- (void)constructWithCenter:(CGPoint)center;
- (void)destroy;
@end