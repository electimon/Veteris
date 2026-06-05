#import "UIColor+Ext.h"
#import "../VAPIHelper/VAPIHelper.h"
@implementation UIColor (ColorTint)
- (UIColor*)tintWithColor:(UIColor*)tintColor {
    return [self tintWithColor:tintColor weight:0.45];
}

- (UIColor*)tintWithColor:(UIColor*)tintColor weight:(CGFloat)weight {
    CGFloat originalRed, originalGreen, originalBlue, originalAlpha;
    CGFloat tintRed, tintGreen, tintBlue, tintAlpha;
    NSArray *components = [UIColor getComponentsOfColor:self];
    originalRed = [(NSNumber *)[components objectAtIndex:0] floatValue];
    originalGreen = [(NSNumber *)[components objectAtIndex:1] floatValue];
    originalBlue = [(NSNumber *)[components objectAtIndex:2] floatValue];
    originalAlpha = [(NSNumber *)[components objectAtIndex:3] floatValue];
    components = [UIColor getComponentsOfColor:tintColor];
    tintRed = [(NSNumber *)[components objectAtIndex:0] floatValue];
    tintGreen = [(NSNumber *)[components objectAtIndex:1] floatValue];
    tintBlue = [(NSNumber *)[components objectAtIndex:2] floatValue];
    tintAlpha = [(NSNumber *)[components objectAtIndex:3] floatValue];
    CGFloat newRed = (originalRed * (1 - weight)) + (tintRed * weight);
    CGFloat newGreen = (originalGreen * (1 - weight)) + (tintGreen * weight);
    CGFloat newBlue = (originalBlue * (1 - weight)) + (tintBlue * weight);
    CGFloat newAlpha = (originalAlpha * (1 - weight)) + (tintAlpha * weight);
    // Return the new tinted color
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

+ (NSArray *)getComponentsOfColor:(UIColor *)color {
    CGFloat red, green, blue, alpha;
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    if (CGColorGetNumberOfComponents(color.CGColor) == 2) {
        red = components[0];
        green = components[0];
        blue = components[0];
        alpha = components[1];
    } else {
        red = components[0];
        green = components[1];
        blue = components[2];
        alpha = components[3];
    }
    
    return @[@(red), @(green), @(blue), @(alpha)];
}

@end