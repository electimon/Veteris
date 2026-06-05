//
//  HomeViewController.m
//  Veteris
//
//  Created by electimon on 1/2/24.
//  Copyright (c) 2024 1pwn. All rights reserved.
//

#import "HomeViewController.h"
#import "../HomeTableViewCell/HomeTableViewCell.h"
#import "../VAPIHelper/VAPIHelper.h"
#import "../../AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "InAppSettingsKit/Models/IASKSettingsReader.h"
#import "InAppSettingsKit/Controllers/IASKAppSettingsViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "../../Reachability/Reachability.h"
#import "../YZTabBar/YZTabBar.h"
#import "../ProtoStack.h"

@implementation HomeViewController {
    NSDictionary *apiResponse;
    NSArray *entries;
    UIBarButtonItem *settingsButton;
}
@synthesize backgroundImage;

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!isiPhone5) {
        // iterate hierarchy because i cant be bothered to make iboutlet
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UIImageView class]] && view.tag == 2) {
                UIImageView *imageView = (UIImageView *)view;
                // enlarge the image
                imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y+11, imageView.frame.size.width, imageView.frame.size.height + 66);
            }
        }
    }
    self.navigationController.title = NSLocalizedString(@"Home", @"Home");
    self.navigationItem.title = NSLocalizedString(@"Home", @"Home");
    self.welcomeLabel.text = NSLocalizedString(@"WelcomeToVeteris", @"WelcomeToVeteris");
    [self.welcomeLabel.text sizeWithFont:self.welcomeLabel.font minFontSize:10 actualFontSize:nil forWidth:self.welcomeLabel.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
    self.tableView.backgroundView = nil;
    self.tableView.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.cornerRadius = 8;
    [self setupBottomBackgroundView];
    entries = nil;
    [getDelegate().themeManager applyThemeToNavigationBar:self.navigationController.navigationBar];
    // Funny easter egg
    [self becomeFirstResponder];

    settingsButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    self.navigationItem.leftBarButtonItem = settingsButton;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconfigure:) name:kPleaseReloadThemes object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNews:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    // Warn user if no internet
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoInternet", nil) message:NSLocalizedString(@"NoInternetMessage", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading", @"") maskType:SVProgressHUDMaskTypeBlack];
        [self loadNews:nil];
    }
    debugLog(@"Reachability: %lu", (long)status);
    if ([getDelegate().themeManager deviceSupportsThemes]) {
        [self setupTopBackgroundView:[getDelegate().themeManager tintColorForCurrentTheme]];
    } else {
        [self setupTopBackgroundView:[UIColor purpleColor]];
    }
    [VAPIHelper showWhatsNewIfNeeded];
    [super viewWillAppear:animated];
}

- (void)loadNews:(NSNotification *)notification {
    [VAPISS getMessage:@"news" completion:^(NSData *data, NSError *error){
        if (error == nil) {
            entries = (NSArray *)(CFBridgingRelease(decode([data bytes], [data length], NewsResponse)));
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD dismiss];
            alert(NSLocalizedString(@"Oops", @""), NSLocalizedString(@"ServerContactError", nil), VAPIHelperErrorNetwork);
        }
    }];
}

- (void)showSettings {
    IASKAppSettingsViewController *appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
    appSettingsViewController.delegate = self;
    appSettingsViewController.showDoneButton = NO;
    appSettingsViewController.showCreditsFooter = NO;
    appSettingsViewController.title = NSLocalizedString(@"Settings", @"");
    if (![getDelegate().themeManager deviceSupportsThemes]) {
        appSettingsViewController.hiddenKeys = [NSSet setWithObjects:@"theme_preference", @"customization_title", nil];
    }
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:appSettingsViewController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissSettingsAnimated)];
    doneButton.style = UIBarButtonItemStyleBordered;
    appSettingsViewController.navigationItem.rightBarButtonItem = doneButton;
    [getDelegate().themeManager applyThemeToNavigationBar:navController.navigationBar];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:getDelegate().window cache:NO];
    UINavigationController *topNavController = (UINavigationController *)((UITabBarController *)getDelegate().window.rootViewController).selectedViewController;
    [topNavController presentViewController:navController animated:NO completion:nil];
    [UIView commitAnimations];
}

- (void)dismissSettingsAnimated {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:getDelegate().window cache:NO];
    [getDelegate().window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    [UIView commitAnimations];
    UINavigationController *topNavController = (UINavigationController *)((UITabBarController *)getDelegate().window.rootViewController).selectedViewController;
    [getDelegate().themeManager applyThemeToNavigationBar:topNavController.navigationBar];
    if ([getDelegate().themeManager deviceSupportsThemes]) {
        settingsButton.tintColor = [getDelegate().themeManager tintColorForCurrentTheme];
    }
}

- (void)reconfigure:(NSNotification *)notification {
    debugLog(@"Reloading theme for HomeViewController");
    [getDelegate().themeManager applyThemeToNavigationBar:self.navigationController.navigationBar];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [super motionBegan:motion withEvent:event];
    if(event.subtype == UIEventSubtypeMotionShake)
    {
        [self setupTopBackgroundView:[UIColor colorWithRed:arc4random_uniform(255)/255.0f green:arc4random_uniform(255)/255.0f blue:arc4random_uniform(255)/255.0f alpha:.7]];
    }
}

- (void)setupTopBackgroundView:(UIColor *)color {
    for (CALayer *layer in self.view.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.backgroundView.bounds;
    gradient.colors = @[
                        (id)[UIColor blackColor].CGColor,
                        (id)[UIColor blackColor].CGColor,
                        (id)color.CGColor,
                        ];
    gradient.locations = @[
                           @0,
                           @0.25,
                           @0.7
                           ];
    [self.view.layer insertSublayer:gradient atIndex:0];
    self.backgroundImage.image = [self imageWithColor:[UIColor blackColor] size:self.backgroundImage.bounds.size];
    self.backgroundImage.alpha = 0.06;
}

- (void)setupBottomBackgroundView {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.backgroundView.bounds;
    gradient.colors = @[
                        (id)[UIColor darkGrayColor].CGColor,
                        (id)[UIColor blackColor].CGColor,
                        (id)[UIColor blackColor].CGColor,
                        ];
    gradient.locations = @[
                           @0,
                           @0.2,
                           @1
                           ];
    [self.backgroundView.layer insertSublayer:gradient atIndex:0];
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)canBecomeFirstResponder
{
#ifdef DEBUG
    bool debug = true;
#else
    bool debug = false;
#endif
    return !debug;
}

#pragma mark UITableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (entries == nil) {
        return 0;
    }
    debugLog(@"Returning %lu", (unsigned long)[entries count]);
    return [entries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HomeTableViewCell";
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NewsPost *post = [entries objectAtIndex:indexPath.row];
    if (post.author != nil) {
        cell.authorLabel.text = post.title;
        cell.contentLabel.text = post.body;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    NewsPost *post = [entries objectAtIndex:indexPath.row];
    if ([post.link length] > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:((NewsPost*)[entries objectAtIndex:indexPath.row]).link]];
    } else {
        alert(NSLocalizedString(@"Oops", @""), NSLocalizedString(@"NoLink", @""), VAPIHelperErrorUnknown);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
