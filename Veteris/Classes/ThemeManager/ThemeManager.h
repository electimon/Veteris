#define kPleaseReloadThemes @"PleaseReloadThemes"
@interface ThemeManager : NSObject
+ (ThemeManager *)sharedInstance;
- (bool)deviceSupportsThemes;
- (UIColor*)tintColorForTheme:(NSString*)themeName;
- (UIColor*)tintColorForCurrentTheme;
- (NSArray*)gradientColorsForTheme:(NSString*)themeName;
- (NSArray*)gradientColorsForCurrentTheme;
- (void)applyThemeToTabBar:(UITabBar *)tabBar;
- (void)applyTintToTabBars;
- (void)applyThemeToNavigationBar:(UINavigationBar *)navigationBar;
- (void)applyTintToNavigationBars;
@end