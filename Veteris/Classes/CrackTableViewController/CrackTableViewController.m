//
//  CrackTableViewController.m
//  Crackulous
//
//  Created by electimon on 6/3/19.
//  Copyright (c) 2019 1pwn. All rights reserved.
//

#import "CrackTableViewController.h"
#import "../CrackTableViewCell/CrackTableViewCell.h"
#import "../NSTask.h"
#import "../../SVProgessHUDUpdated/SVProgressHUDUpdated.h"


@interface CrackTableViewController ()

@end

@implementation CrackTableViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.sortedApps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CrackTableViewCell";
    CrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *appBundleId = [self.sortedAppsKeys objectAtIndex:indexPath.row];
    
    @try {
        cell.cellLabel.text = [[[self.sortedApps valueForKey:appBundleId] valueForKey:@"CFBundleName"] objectAtIndex:0];
    }
    @catch (NSException *exception) {
        NSLog(@"Crackulous: Bug: %@", exception);
        cell.cellLabel.text = [[[self.sortedApps valueForKey:appBundleId] valueForKey:@"CFBundleDisplayName"] objectAtIndex:0];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [SVProgressHUDUpdated showWithStatus:@"Cracking..."];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    NSString *appBundleId = [self.sortedAppsKeys objectAtIndex:indexPath.row];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/clutch"];
    
    NSString *arguments = [NSString stringWithFormat:@"%@", [[[self.sortedApps valueForKey:appBundleId] valueForKey:@"CFBundleExecutable"] objectAtIndex:0]];
    
    [task setArguments:@[arguments]];
    
    [task setStandardOutput:[NSPipe new]];
    [task setStandardError:[task standardOutput]];
    
    [task launch];
    
    
    NSFileHandle *readHandle = [[task standardOutput] fileHandleForReading];
    
    
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(getReadTaskData:)
                           name:NSFileHandleReadCompletionNotification
                           object:readHandle];
    
    [readHandle readInBackgroundAndNotify];
    
    
    
}

-(void)getReadTaskData: (NSNotification *)aNotification {
    
    NSData *data = [[aNotification userInfo] objectForKey:@"NSFileHandleNotificationDataItem"];
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self parseReadTaskData:response];
    
}

-(void)parseReadTaskData:(NSString *)response {

#warning Uncomment when debugging
    //[self showUIAlertView:@"Debug" message:response cancelButtonTitle:@"Debug"];
    
    if ([response rangeOfString:@"must be root"].location == NSNotFound) {

    } else {
        
        [self showUIAlertView:@"Oops!" message:@"You must be running Crackulous as root!" cancelButtonTitle:@"Ok"];
//#warning "Uncomment for release"
        
        //exit(EXIT_FAILURE);
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [SVProgressHUDUpdated dismiss];
    }
    
    if ([response rangeOfString:@".ipa"].location == NSNotFound) {
        
        [self showUIAlertView:@"Oops!" message:@"Something went wrong, Clutch should be version 1.1.2, this app is most likely just uncrackable!" cancelButtonTitle:@"Ok"];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [SVProgressHUDUpdated dismiss];
    } else {
        
        [self showUIAlertView:@"Done!" message:[NSString stringWithFormat:@"You can find the iPA here: /%@/root/Documents/Cracked/%@", [response componentsSeparatedByString:@"/"][1], [response componentsSeparatedByString:@"/"][5]] cancelButtonTitle:@"Ok"];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [SVProgressHUDUpdated dismiss];
    }
    
}

-(void)showUIAlertView:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)CBTitle {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:CBTitle otherButtonTitles:nil] show];
}

@end
