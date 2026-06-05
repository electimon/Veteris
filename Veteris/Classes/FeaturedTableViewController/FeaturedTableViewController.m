//
//  FeaturedTableViewController.m
//  Veteris
//
//  Created by electimon on 6/7/19.
//  Copyright (c) 2022 Electimon. All rights reserved.
//

#import "FeaturedTableViewController.h"
#import "FeaturedTableViewCell.h"
#import "../AppInfo/AppInfo.h"
#import "../VAPIHelper.h"
#import "../../AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "../../SVProgressHUD/SVProgressHUD.h"
#import "../../KeychainItemWrapper.h"
@interface FeaturedTableViewController ()

@end

@implementation FeaturedTableViewController {
    NSArray *apiResponseArray;
    NSDictionary *apiResponse;
    NSOperationQueue *queue;
    AppDelegate *delegate;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    queue = [[NSOperationQueue alloc] init];
    
    delegate = [[UIApplication sharedApplication] delegate];
    
    [self reloadAccountStatus];
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeBlack];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        apiResponse = [VAPIHelper apiGet:@"listing/recommended"];
        apiResponseArray = [apiResponse objectForKey:@"applications"];
        if (apiResponse == nil) {
            apiResponse = [VAPIHelper apiGet:@"listing/recommended"];
            if (apiResponse == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil, nil];
                [alertView show];
            }
            [SVProgressHUD dismiss];
        }
        [[self tableView] reloadData];
        [SVProgressHUD dismiss];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadAccountStatus {
    if (delegate.authTokenPresent) {
        self.signinButton.enabled = NO;
        self.signinButton.title = @"Signed In";
        self.registerButton.enabled = NO;
    } else {
        self.signinButton.enabled = true;
        self.signinButton.title = @"Log In";
        self.registerButton.enabled = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [apiResponseArray count];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FeaturedTableViewCell";
    
    FeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.tag = indexPath.row;
    
    [cell.activityIndicator startAnimating];
    cell.appNameLabel.text = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    cell.developerNameLabel.text = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"developer"];
    
    cell.versionLabel.text = [NSString stringWithFormat:@"Version: %@", [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"version"]];
    if (cell.appUIImage.image == nil) {
        NSString *iconURL = [NSString stringWithFormat:@"%@%@", delegate.apiBaseURL, [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"iconurl"]];
        UIImage *image = [delegate.imageCache objectForKey:iconURL];
        if (image) {
            cell.appUIImage.image = image;
            [cell.activityIndicator stopAnimating];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSInteger tag = cell.tag;
                NSURL *imageURL = [NSURL URLWithString:[iconURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                NSData* imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (!cell.appUIImage.image && cell.tag == tag) {
                        [cell.activityIndicator stopAnimating];
                        cell.appUIImage.image = [UIImage imageWithData:imageData];
                        if (cell.appUIImage.image) {
                            [delegate.imageCache setObject:cell.appUIImage.image forKey:iconURL];
                        }
                    }
                    cell.indicatorCounter = 1;
                    cell.appUIImage.layer.masksToBounds = YES;
                    cell.appUIImage.layer.cornerRadius = 13.0;
                }];
            });
        }
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"FeaturedAppInfoPush"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        FeaturedTableViewCell *cell = (FeaturedTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        
        AppInfo *appinfo = segue.destinationViewController;
        appinfo.appName = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        appinfo.appDeveloperName = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"developer"];
        appinfo.appBundleID = [[apiResponseArray objectAtIndex:indexPath.row] valueForKey:@"bundleid"];
        
        appinfo.appImage = cell.appUIImage.image;
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:@"Quit"])
    {
        if (!delegate.debugOn) {
            //home button press programmatically
            UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)];
        
            //wait 2 seconds while app is going background
            [NSThread sleepForTimeInterval:2.0];
        
            //exit app when app is in background except when debugging is enabled
            exit(0);
        }
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:@"Connect"]) {
        NSString *username = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        NSDictionary *response = [VAPIHelper apiLogin:username password:password];
        if (response) {
            NSString *status = [response valueForKey:@"status"];
            NSString *content = [response valueForKey:@"content"];
            NSString *message = [response valueForKey:@"message"];
            if ([status isEqual:@"Error"]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                //[delegate.keychain setObject:content forKey:(__bridge id)kSecValueData];
                //[delegate.keychain setObject:username forKey:(__bridge id)kSecAttrAccount];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:content forKey:@"token"];
                [defaults setValue:username forKey:@"username"];
                delegate.authTokenPresent = YES;
                [self reloadAccountStatus];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Failed to contact server!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:@"Register"]) {
        NSString *username = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        NSDictionary *response = [VAPIHelper apiRegister:username password:password];
        if (response) {
            NSString *status = [response valueForKey:@"status"];
            NSString *content = [response valueForKey:@"content"];
            NSString *message = [response valueForKey:@"message"];
            if ([status isEqual:@"Error"]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                //[delegate.keychain setObject:content forKey:(__bridge id)kSecValueData];
                //[delegate.keychain setObject:username forKey:(__bridge id)kSecAttrAccount];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:content forKey:@"token"];
                [defaults setValue:username forKey:@"username"];
                delegate.authTokenPresent = YES;
                [self reloadAccountStatus];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Failed to contact server!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (IBAction)signinButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign In" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
}
- (IBAction)registerButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Make an account" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Register", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
}
@end
