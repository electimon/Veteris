//
//  SettingsTableViewController.m
//  Veteris
//
//  Created by electimon on 5/21/20.
//  Copyright (c) 2020 1pwn. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsTableViewController.h"
#import "VAPIHelper.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController {
    NSDictionary *returnDict;
    AppDelegate *appdelegate;
    NSUserDefaults *defaults;
}
@synthesize usernameField;
@synthesize passwordField;

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
    
    appdelegate = [[UIApplication sharedApplication] delegate];
    defaults = [NSUserDefaults standardUserDefaults];
    
    if (!([defaults objectForKey:@"username"] == NULL)) {
        usernameField.text = [defaults objectForKey:@"username"];
        passwordField.text = @"123456789";
    }
    
    self.passwordField.delegate = self;
    
    [usernameField addTarget:passwordField action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSLog(@"username = %@", [defaults objectForKey:@"username"]);
    
    NSString *post = [NSString stringWithFormat:@"username=%@&password=%@", usernameField.text, passwordField.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.veteris.xyz/1.0/login"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    NSDictionary *tempDict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
  
    NSLog(@"tempdict = %@", tempDict);
    
    if ([[tempDict objectForKey:@"error"] isEqual:@"incorrect_information"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Wrong login information provided!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
    
    if (!([tempDict objectForKey:@"error"])) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You are now logged in!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [defaults setObject:[tempDict valueForKey:@"refresh"] forKey:@"refresh"];
    [defaults setObject:[tempDict valueForKey:@"username"] forKey:@"username"];
    
    [defaults synchronize];
    }
    
    return NO;
}

@end
