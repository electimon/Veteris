#import "ThemeManager.h"
#import "../VAPIHelper/VAPIHelper.h"
#import "../Convenience/Convenience.h"
#import "../../AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "InAppSettingsKit/Models/IASKSettingsReader.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define KILL_IF_UNSUPPORTED if (THEME_KILLSWITCH == 1) { return; }

@implementation ThemeManager {
    NSDictionary *themeInfo;
    NSString *currentTheme;
    bool THEME_KILLSWITCH;
}

+ (ThemeManager *)sharedInstance {
    static ThemeManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ThemeManager alloc] init];
        [NSNotificationCenter.defaultCenter addObserver:sharedInstance selector:@selector(reconfigure:) name:kIASKAppSettingChanged object:nil];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        themeInfo = [self defaultThemeInfo];
        currentTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"theme_preference"];
        if (currentTheme == nil) {
            currentTheme = @"Default";
        }
        if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
            THEME_KILLSWITCH = 1; // ios 5 has trouble with navigation bar themes
        }
    }
    return self;
}
- (NSDictionary*)defaultThemeInfo {
    if (THEME_KILLSWITCH == 1) {
        return @{};
    }
    return @{
        @"Default": @{
            @"name": @"Default",
            @"tintColor": [UIColor darkGrayColor],
            @"gradientColors": @[
                (id)UIColorFromRGB(0x2C2C2C).CGColor,
                (id)UIColorFromRGB(0x1E1E1E).CGColor,
                (id)UIColorFromRGB(0x121212).CGColor,
                (id)UIColorFromRGB(0x000000).CGColor
            ]
        },
        @"Jungle": @{
            @"name": @"Jungle",
            @"tintColor": [UIColor colorWithRed:0.30 green:0.55 blue:0.22 alpha:1.0],
            @"gradientColors": @[
                (id)UIColorFromRGB(0x4D7330).CGColor,
                (id)UIColorFromRGB(0x3C5A27).CGColor,
                (id)UIColorFromRGB(0x2E4720).CGColor,
                (id)UIColorFromRGB(0x22351A).CGColor
            ]
        },
        @"Frost": @{
            @"name": @"Frost",
            @"tintColor": [UIColor colorWithRed:0.35 green:0.55 blue:0.60 alpha:1.0],
            @"gradientColors": @[
                (id)UIColorFromRGB(0x8BA7B3).CGColor,
                (id)UIColorFromRGB(0x6F8B97).CGColor,
                (id)UIColorFromRGB(0x56707C).CGColor,
                (id)UIColorFromRGB(0x43575F).CGColor
            ]
        },
        @"Cherry": @{
            @"name": @"Cherry Blossom",
            @"tintColor": [UIColor colorWithRed:0.90 green:0.65 blue:0.75 alpha:1.0],
            @"gradientColors": @[
                (id)UIColorFromRGB(0xF2B7C1).CGColor,
                (id)UIColorFromRGB(0xD89AA9).CGColor,
                (id)UIColorFromRGB(0xC57F8F).CGColor,
                (id)UIColorFromRGB(0x9E626F).CGColor
            ]
        },
        @"Autumn": @{
            @"name": @"Autumn",
            @"tintColor": [UIColor colorWithRed:0.60 green:0.30 blue:0.05 alpha:1.0],
            @"gradientColors": @[
                (id)UIColorFromRGB(0x8A4315).CGColor,
                (id)UIColorFromRGB(0x6F3410).CGColor,
                (id)UIColorFromRGB(0x55260C).CGColor,
                (id)UIColorFromRGB(0x3D1A09).CGColor
            ]
        },
        @"Spooky": @{
            @"name": @"Spooky",
            @"tintColor": [UIColor purpleColor],
            @"gradientColors": @[
                (id)UIColorFromRGB(0x454545).CGColor,
                (id)UIColorFromRGB(0x393939).CGColor,
                (id)UIColorFromRGB(0x272726).CGColor,
                (id)UIColorFromRGB(0x19191A).CGColor
            ]
        },
        @"Periwinkle": @{
            @"name": @"Periwinkle",
            @"tintColor": [UIColor colorWithRed:0.55 green:0.55 blue:0.85 alpha:1.0],
            @"gradientColors": @[
                (id)UIColorFromRGB(0x5F5F9C).CGColor,
                (id)UIColorFromRGB(0x4B4B7D).CGColor,
                (id)UIColorFromRGB(0x39395E).CGColor,
                (id)UIColorFromRGB(0x292941).CGColor
            ]
        }
    };
}

- (bool)deviceSupportsThemes {
    return THEME_KILLSWITCH == 0;
}

#pragma mark - Theme Management

- (UIColor*)tintColorForTheme:(NSString*)themeName {
    return [[themeInfo objectForKey:themeName] objectForKey:@"tintColor"];
}

- (UIColor*)tintColorForCurrentTheme {
    return [self tintColorForTheme:currentTheme];
}

- (NSArray*)gradientColorsForTheme:(NSString*)themeName {
    debugLog(@"themeName: %@", themeName);
    return [[themeInfo objectForKey:themeName] objectForKey:@"gradientColors"];
}

- (NSArray*)gradientColorsForCurrentTheme {
    return [self gradientColorsForTheme:currentTheme];
}

#pragma mark - Theme Application
- (void)applyThemeToTabBar:(UITabBar *)tabBar {
    KILL_IF_UNSUPPORTED;
    UIView *bgView = [self findTabBarBackgroundView:tabBar];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    }
    [self cleanViewOfGradientLayers:bgView];
    CAGradientLayer *gradientLayer = [self createGradientLayerForCurrentThemeWithFrame:bgView.bounds];
    [bgView.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)applyTintToTabBars {
    KILL_IF_UNSUPPORTED;
    [UITabBar.appearance setTintColor:[self tintColorForCurrentTheme]];
    [UITabBar.appearance setSelectedImageTintColor:[self tintColorForCurrentTheme]];
    [UITabBarItem.appearance setTitleTextAttributes:@{UITextAttributeTextColor: [self tintColorForCurrentTheme]} forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:@{UITextAttributeTextColor: [[UIColor whiteColor] tintWithColor:[self tintColorForCurrentTheme]]} forState:UIControlStateSelected];
}

- (void)applyThemeToNavigationBar:(UINavigationBar *)navigationBar {
    KILL_IF_UNSUPPORTED;
    UIView *bgView = [self findNavigationBarBackgroundView:navigationBar];
    [self cleanViewOfGradientLayers:bgView];
    CAGradientLayer *gradientLayer = [self createGradientLayerForCurrentThemeWithFrame:navigationBar.bounds];
    [bgView.layer insertSublayer:gradientLayer atIndex:0];
    [bgView setNeedsDisplay];
    // set tint color here anyway, sometimes the shown viewcontroller doesnt get redrawn
    [navigationBar setTintColor:[self tintColorForCurrentTheme]];
}

- (void)applyTintToNavigationBars {
    KILL_IF_UNSUPPORTED;
    [UINavigationBar.appearance setTintColor:[self tintColorForCurrentTheme]];
}

#pragma mark - View Helpers
- (UIView *)findTabBarBackgroundView:(UITabBar *)tabBar {
    for (UIView *view in tabBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"_UITabBarBackgroundView")]) {
            return view;
        }
    }
    return nil;
}

- (UIView *)findNavigationBarBackgroundView:(UINavigationBar *)navigationBar {
    for (UIView *view in navigationBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            return view;
        }
    }
    return nil;
}

#pragma mark - Layer Helpers
- (void)cleanViewOfGradientLayers:(UIView *)view {
    for (CALayer *layer in [view.layer.sublayers copy]) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
}

#pragma mark - Gradient Layer Creation
- (CAGradientLayer *)createGradientLayerWithColors:(NSArray *)baseColors tintColor:(UIColor *)tintColor frame:(CGRect)frame {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    
    NSMutableArray *tintedColors = [NSMutableArray array];
    for (id cgColor in baseColors) {
        UIColor *color = [UIColor colorWithCGColor:(__bridge CGColorRef)cgColor];
        UIColor *tintedColor = [color tintWithColor:tintColor];
        [tintedColors addObject:(id)tintedColor.CGColor];
    }
    
    gradient.colors = tintedColors;
    return gradient;
}

- (CAGradientLayer *)createGradientLayerForCurrentThemeWithFrame:(CGRect)frame {
    return [self createGradientLayerWithColors:[self gradientColorsForCurrentTheme] tintColor:[self tintColorForCurrentTheme] frame:frame];
}

#pragma mark - Misc
- (void)reconfigure:(NSNotification *)notification {
    debugLog(@"notification: %@", notification);
    if (![(NSString*)notification.object isEqualToString:@"theme_preference"]) {
        debugLog(@"Not a theme change, ignoring");
        return;
    }
    if (![self deviceSupportsThemes]) {
        debugLog(@"Device does not support themes, ignoring");
        return;
    }
    currentTheme = [[notification userInfo] valueForKey:@"theme_preference"];
    [NSNotificationCenter.defaultCenter postNotificationName:kPleaseReloadThemes object:nil];   
    UIViewController *shownVC = [getDelegate().window visibleViewController];
    if (shownVC.navigationController != nil) {
        [self applyThemeToNavigationBar:shownVC.navigationController.navigationBar];
    }
    [self applyTintToTabBars];
    [self applyTintToNavigationBars];
}
@end