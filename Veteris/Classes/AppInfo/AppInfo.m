//
//  AppInfo.m
//  Veteris
//
//  Created by electimon on 6/8/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "AppInfo.h"
#import "../VAPIHelper.h"
#import "../../SVProgressHUD/SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface AppInfo ()

@end

@implementation AppInfo {
    NSDictionary *apiResponse;
    NSOperationQueue *queue;
}
@synthesize getButton;
@synthesize appNameLabel;
@synthesize appUIImage;
@synthesize appDeveloperNameLabel;



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
    
    queue = [[NSOperationQueue alloc] init];
    
    self.appDeveloperNameLabel.text = self.appDeveloperName;
    self.appNameLabel.text = self.appName;
    
    self.appUIImage.image = self.appImage;
    
    appUIImage.layer.masksToBounds = YES;
    appUIImage.layer.cornerRadius = 13.0;
    
    apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"app/%@", self.appBundleID]];
    
    if (apiResponse == nil) {
        apiResponse = [VAPIHelper apiGet:[NSString stringWithFormat:@"app/%@", self.appBundleID]];
        if (apiResponse == nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The server could not be contacted, try again later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
    }
    
    if (self.appUIImage.image == NULL) {
        [queue addOperationWithBlock:^{
            
            NSURL *imageURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/128x0w.jpg",[apiResponse  valueForKey:@"iconurl"]]];
            
            NSLog(@"imageURL = %@", imageURL);
            
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
                appUIImage.image = [UIImage imageWithData:imageData];
            
            }];
        }];
    }
    
    self.appDescriptionLabel.text = [apiResponse valueForKey:@"description"];
    
    //[self.appDescriptionLabel sizeToFit];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)getButtonPressed:(id)sender {
    
    [SVProgressHUD showInView:self.view status:@"Installing..." networkIndicator:NO posY:-1 maskType:SVProgressHUDMaskTypeBlack];
    
    if ([[[apiResponse objectForKey:@"versions"] valueForKey:@"version"] count] > 0) {
        
        [queue addOperationWithBlock:^{
            
            BOOL ret = [VAPIHelper fetchAndInstallApp:[apiResponse valueForKey:@"bundleid"] appDictionary:apiResponse];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                if (ret == YES) {
                    
                    [SVProgressHUD dismiss];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Installed" message:[NSString stringWithFormat:@"%@ has been installed", [apiResponse valueForKey:@"name"]] delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                    
                    [alertView show];
                    
                } else {
                    
                    [SVProgressHUD dismiss];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@ has NOT been installed, make sure you're running as root", [apiResponse valueForKey:@"name"]] delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
                    
                    [alertView show];
                }
            }];
        }];
        
    } else {
        
        [SVProgressHUD dismiss];

         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@ has NOT been installed, no versions available.", [apiResponse valueForKey:@"name"]] delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [alertView show];
        
    }
}

@end
