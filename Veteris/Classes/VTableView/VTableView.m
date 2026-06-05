
#import "VTableView.h"
#import <QuartzCore/QuartzCore.h>
#import "../../AppDelegate.h"
#import "../AppInfo/AppInfo.h"
#import "../FeaturedTableViewController/FeaturedTableViewCell.h"
#import "../VAPIHelper/VAPIHelper.h"
#import "InAppSettingsKit/Models/IASKSettingsReader.h"
#import "../ProtoStack.h"
#import "../LoadingIndicatorView/LoadingIndicatorView.h"

@implementation VTableView {
    NSString *_endpoint;
    LoadingIndicatorView *loadingIndicator;
    UILabel *errorLabel;
    bool inInit;
    int firstAppear;
}
@synthesize applications;

- (void)initialize:(NSString *)endpoint {
    [self initialize:endpoint skipIndicator:NO];
}

- (void)initialize:(NSString *)endpoint skipIndicator:(BOOL)skipIndicator {
    inInit = YES;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(reconfigure:) name:kPleaseReloadThemes object:nil];
    debugLog(@"Initializing with endpoint: %@", endpoint);
    _endpoint = endpoint;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.frame];
    self.tableView.backgroundView.backgroundColor = [UIColor whiteColor];
    if (!skipIndicator) {
        loadingIndicator = [LoadingIndicatorView attachToView:getDelegate().window];
    }

    if (errorLabel == nil) {
        errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        errorLabel.text = NSLocalizedString(@"FailedToLoadContent", nil);
        [errorLabel sizeToFit];
        errorLabel.textColor = [UIColor grayColor];
        errorLabel.backgroundColor = [UIColor clearColor];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.center = CGPointMake(self.tableView.center.x, getDelegate().window.center.y);
    }

    [VAPISS getMessage:endpoint completion:^(NSData *data, NSError *error){
        if (error == nil) {
            applications = (NSMutableArray *)(CFBridgingRelease(decode([data bytes], [data length], VTableResponse)));
            if (!skipIndicator) {
                [loadingIndicator destroy];
                loadingIndicator = nil; // kaboom
            }
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [self.tableView reloadData];
            [errorLabel removeFromSuperview];
        } else {
            if (!skipIndicator) {
                [loadingIndicator destroy];
                loadingIndicator = nil; // btooom
            }
            alert(NSLocalizedString(@"Oops", @""), NSLocalizedString(@"ServerContactError", nil), VAPIHelperErrorNetwork);
            [getDelegate().window addSubview:errorLabel];
        }
    }];
    inInit = NO;
    firstAppear = NO;
}

- (void)reconfigure:(NSNotification *)notification {
    [getDelegate().themeManager applyThemeToNavigationBar:self.navigationController.navigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    firstAppear = 3;
    if (loadingIndicator != nil) {
        [loadingIndicator destroy];
        loadingIndicator = nil;
    }
    if (errorLabel != nil) {
        [errorLabel removeFromSuperview];
        errorLabel = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    debugLog(@"conditions: %d %d %d %d", applications == nil, _endpoint != nil, loadingIndicator == nil, !inInit);
    if (applications == nil && _endpoint != nil && loadingIndicator == nil && !inInit && firstAppear == 3) {
        [self initialize:_endpoint];
    }
    [getDelegate().themeManager applyThemeToNavigationBar:self.navigationController.navigationBar];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [applications count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 78;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FeaturedTableViewCell";
    FeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    [cell.activityIndicator startAnimating];
    Application *app = [applications objectAtIndex:indexPath.row];

    cell.tag = indexPath.row;
    cell.appNameLabel.text = app.name;
    cell.developerNameLabel.text = app.developer;
    cell.versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version", nil), app.version];
    [cell.activityIndicator startAnimating];
    NSUInteger tag = cell.tag;
    [VAPISS getStatic:app.iconurl completion:^(NSData *data, NSError *error){
        if (error == nil) {
            if (tag != cell.tag) {
                return; // its fine to return, the image is already cached by getStatic
            }
            cell.appUIImage.image = [UIImage imageWithData:data];
            if (cell.appUIImage.image == nil) {
                debugLog(@"Failed to load image for %@, bundleid: %@, app image url: %@", app.name, app.bundleid, app.iconurl);
            }
            [cell.activityIndicator stopAnimating];
            cell.indicatorCounter = 1;
            cell.appUIImage.layer.masksToBounds = YES;
            cell.appUIImage.layer.cornerRadius = 13.0;
        } else {
            debugLog(@"Oopsie :3 failed to load image for %@, bundleid: %@, app image url: %@", app.name, app.bundleid, app.iconurl);
        }
    }];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier rangeOfString:@"AppInfoPush"].location != NSNotFound) {

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        FeaturedTableViewCell *cell = (FeaturedTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

        AppInfo *appinfo = segue.destinationViewController;
        Application *app = [applications objectAtIndex:indexPath.row];
        [appinfo initialize:app.bundleid developer:app.developer name:app.name image:cell.appUIImage.image];
    }
}
@end
