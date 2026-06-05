#import "YZTabBar.h"
#import "../../AppDelegate.h"

@implementation YZTabBar
@synthesize needsApplyTheme;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registerForThemeChanges];
        self.needsApplyTheme = true;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerForThemeChanges];
        self.needsApplyTheme = true;
    }
    return self;
}

- (void)registerForThemeChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:kPleaseReloadThemes object:nil];
}

- (void)themeChanged:(NSNotification *)notification {
    self.needsApplyTheme = true;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    debugLog(@"tabbar height: %f", self.frame.size.height);
    if (self.needsApplyTheme) {
        [getDelegate().themeManager applyThemeToTabBar:self];
        self.needsApplyTheme = false;
    }
}

@end
