#import <UIKit/UIKit.h>

@interface UIColor (ColorTint)
- (UIColor *)tintWithColor:(UIColor *)tintColor;
- (UIColor*)tintWithColor:(UIColor*)tintColor weight:(CGFloat)weight;
@end