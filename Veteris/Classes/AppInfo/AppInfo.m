//
//  AppInfo.m
//  Veteris
//
//  Created by electimon on 6/8/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "AppInfo.h"
#include <Foundation/NSBundle.h>
#import <QuartzCore/QuartzCore.h>
#import "../../AppDelegate.h"
#import "../../SVProgressHUD/SVProgressHUD.h"
#import "../ProtoStack.h"
#import "../Protos/Application.h"
#import "../VAPIHelper/VAPIHelper.h"
#import "../YZQueue/YZQueueManager.h"

@implementation AppInfo {
    AppDelegate *delegate;
    UIImage *appImage;
    BOOL initialized;
    Application *app;
}
@synthesize getButton;
@synthesize appNameLabel;
@synthesize appUIImage;
@synthesize appDeveloperNameLabel;
@synthesize activityIndicator;
@synthesize descriptionLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = getDelegate();
    appUIImage.layer.masksToBounds = YES;
    appUIImage.layer.cornerRadius = 13.0;
    activityIndicator.hidden = YES;
    self.navigationItem.title = NSLocalizedString(@"Info", nil);
    self.descriptionLabel.text = NSLocalizedString(@"Description", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [getDelegate().themeManager applyThemeToNavigationBar:self.navigationController.navigationBar];
}

- (void)didReceiveInstallationStartedNotification:(NSNotification *)notification {
    debugLog(@"Installation started notification received");
}

- (void)initialize:(NSString *)bundleID developer:(NSString *)developer name:(NSString *)name image:(UIImage *)image {
    debugLog(@"Initializing with bundleID: %@ developer: %@ name: %@", bundleID, developer, name);
    debugLog(@"Versions: %@", app.versions);
    dispatch_async(dispatch_get_main_queue(), ^{
        activityIndicator.hidden = NO;
        [activityIndicator startAnimating];
        if (developer != nil || name != nil || image != NULL) {
            self.appDeveloperNameLabel.text = developer;
            self.appNameLabel.text = name;
            self.appUIImage.image = image;
        }
    });
    [VAPISS getMessage:[NSString stringWithFormat:@"listing/app/%@", bundleID] completion:^(NSData *data, NSError *error) {
        if (error) {
            [SVProgressHUD dismiss];
            alert(NSLocalizedString(@"Oops", nil), NSLocalizedString(@"ServerContactError", nil), VAPIHelperErrorNetwork);
            return;
        }
        app = (Application *)(CFBridgingRelease(decode([data bytes], [data length], AppResponse)));
        self.appDescriptionLabel.text = [NSString stringWithFormat:@"\n%@", app.app_description];
        [self.appDescriptionLabel sizeToFit];
        [self loadImageIfNeeded];
        self.appDeveloperNameLabel.text = app.developer;
        self.appNameLabel.text = app.name;
        // Check if label is a subview of the scroll view
        if ([self.appDescriptionLabel isDescendantOfView:self.scrollView]) {
            // Update content size after label has been sized
            self.scrollView.contentSize = self.appDescriptionLabel.bounds.size;
        }
        initialized = YES;
    }];
}

- (void)initialize:(NSString *)bundleID {
    [self initialize:bundleID developer:nil name:nil image:NULL];
}

- (void)loadImageIfNeeded {
    if (self.appUIImage.image == NULL) {
        [VAPISS getStatic:app.iconurl completion:^(NSData *data, NSError *error){
            if (error != nil) {
                debugLog(@"Failed to fetch image for %@", app.bundleid);
                return;
            }
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                appUIImage.image = image;
                app.icon = image;
                [activityIndicator stopAnimating];
                activityIndicator.hidden = YES;
            });
        }];
    }
}

- (IBAction)getButtonPressed:(id)sender {
    if (!initialized) {
        alert(NSLocalizedString(@"Oops", nil), NSLocalizedString(@"WaitForAppFinishLoading", nil), VAPIHelperErrorUnknown);
        return;
    }
    // Set initialized here because if the button is pressed the view must be fully loaded
    initialized = YES;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SelectAVersion", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    for (Version *ver in app.versions) {
        [actionSheet addButtonWithTitle:ver.version];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet setCancelButtonIndex:[app.versions count]];
    [actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [app.versions count]) {
        return;
    }
    if ([app.versions count] > 0) {
        YZApplication *yzApp = [[YZApplication alloc] initFromApp:app version:[app.versions objectAtIndex:buttonIndex]];
        [YZQueueManager enqueueYZApplicationForDownload:yzApp];
    } else {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"NoVersionsAvailable", @"%@ has NOT been installed, no versions available."), app.name];
        alert(@"Error", message, VAPIHelperErrorUnknown);
    }
}
@end
