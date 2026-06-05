//
//  AppInfo.m
//  Veteris
//
//  Created by electimon on 6/8/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "AppInfo.h"
#import "../VAPIHelper.h"
#import "../../SVProgressHUD/SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "../../AppDelegate.h"
#import "../../ActionSheetPicker/ActionSheetCustomPicker.h"
#import "../../ActionSheetPicker/ActionSheetStringPicker.h"

@interface AppInfo ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation AppInfo {
    NSDictionary *apiResponse;
    NSOperationQueue *queue;
    AppDelegate *delegate;
}
@synthesize getButton;
@synthesize appNameLabel;
@synthesize appUIImage;
@synthesize appDeveloperNameLabel;
@synthesize alertView=_alertView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _alertView = [[UIAlertView alloc] initWithTitle:@"Cancel" message:@"Do you wish to cancel the installation?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    _alertView.tag = 0;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(userDidTouchOutsideOfHUD:) name:@"SVProgressHUDDidReceiveTouchEventNotificationNotTouchingHUD" object:nil];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    delegate = [[UIApplication sharedApplication] delegate];
    
    if (!delegate.authTokenPresent) {
        self.reportButton.enabled = NO;
    }
    
    queue = [[NSOperationQueue alloc] init];
    
    self.appDeveloperNameLabel.text = self.appDeveloperName;
    self.appNameLabel.text = self.appName;
    
    self.appUIImage.image = self.appImage;
    
    appUIImage.layer.masksToBounds = YES;
    appUIImage.layer.cornerRadius = 13.0;
    
    apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"listing/app/%@", self.appBundleID]];
    
    if (apiResponse == nil) {
        apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"listing/app/%@", self.appBundleID]];
        if (apiResponse == nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }
    
    if (self.appUIImage.image == NULL) {
        [queue addOperationWithBlock:^{
            NSString *iconURL = [NSString stringWithFormat:@"%@%@", delegate.apiBaseURL, [apiResponse  valueForKey:@"iconurl"]];
            NSURL *imageURL = [NSURL URLWithString:[iconURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                appUIImage.image = [UIImage imageWithData:imageData];
                
            }];
        }];
    }
    
    self.appDescriptionLabel.text = [apiResponse valueForKey:@"description"];

    [self.appDescriptionLabel sizeToFit];
    self.scrollView.contentSize = self.appDescriptionLabel.bounds.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getButtonPressed:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if (delegate.installingBool == true || delegate.downloadingBool == true) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"A application is currently being installed, please wait!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        } else {
            if ([[apiResponse objectForKey:@"versions"] count] > 0) {
                [SVProgressHUD showWithStatus:@"Connecting..." maskType:SVProgressHUDMaskTypeBlack];
                delegate.navigationController = self.navigationController;
                [delegate._VAPIHelper fetchAndInstallAppForViewController:selectedIndex appDictionary:apiResponse withAlertView:_alertView];
                delegate.downloadingBool = true;
                self.view.userInteractionEnabled = false;
                self.navigationController.tabBarController.view.userInteractionEnabled = false;
            } else {
                delegate.downloadingBool = false;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@ has NOT been installed, no versions available.", [apiResponse valueForKey:@"name"]] delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                [alertView show];
            } 
        }
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
    };
    NSMutableArray *versions = [[NSMutableArray alloc] init];
    for (NSDictionary *key in [apiResponse objectForKey:@"versions"]) {
        [versions addObject:[[key allKeys] objectAtIndex:0]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Version" rows:versions initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)reportButtonPressed:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        // Todo, error handling, apiReportApp returns a response...
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report Reason" message:@"Please enter the issue you are having with this App." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = 1;
        [alertView.layer setValue:[NSNumber numberWithInt:selectedIndex] forKey:@"reportedIndex"];
        [alertView show];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
    };
    NSMutableArray *versions = [[NSMutableArray alloc] init];
    for (NSDictionary *key in [apiResponse objectForKey:@"versions"]) {
        [versions addObject:[[key allKeys] objectAtIndex:0]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Version to report" rows:versions initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
}

-(void)userDidTouchOutsideOfHUD:(NSNotification *)notification {
    if (!delegate.installingBool) {
        [_alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Cancel download alertview
    if (alertView.tag == 0 && buttonIndex == 0) {
        [delegate._VAPIHelper stopDownload];
        [SVProgressHUD dismiss];
        delegate.navigationController.topViewController.view.userInteractionEnabled = true;
        delegate.navigationController.tabBarController.view.userInteractionEnabled = true;
        delegate.downloadingBool = false;
        delegate.installingBool = false;
    }
    // Report app alertview
    if (alertView.tag == 1 && buttonIndex == 1) {
        UIAlertView *alertView;
        if ([[alertView textFieldAtIndex:0].text length] > 0) {
            NSDictionary *response = [VAPIHelper apiReportApp:self.appBundleID version:[[[[apiResponse objectForKey:@"versions"] objectAtIndex:[(NSNumber *)[alertView.layer valueForKey:@"reportedIndex"] integerValue]] allKeys] objectAtIndex:0] reason:[alertView textFieldAtIndex:0].text];
            if ([[response valueForKey:@"status"] isEqualToString:@"Error"]) {
                alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:[response valueForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            } else {
                alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Application reported successfully! Thank you." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        } else {
            alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please specify a reason!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void)didSwipe:(UISwipeGestureRecognizer*)swipe {
    if ([[[UIDevice currentDevice] model]  isEqual: @"iPad"]) {
        UINavigationController *naviController = self.navigationController;
        [naviController popViewControllerAnimated:YES];
    }
}
@end
