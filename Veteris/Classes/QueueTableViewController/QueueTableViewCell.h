#import <UIKit/UIKit.h>
#import "../VAPIHelper/VAPIHelper.h"
#import "../Protos/Application.h"
#import "../Protos/Version.h"
#import "../ProtoStack.h"
#import "../YZQueue/YZQueueRep.h"

@interface QueueTableViewCell : UITableViewCell
@property (nonatomic, retain) UILabel *appNameLabel;
@property (nonatomic, retain) UILabel *appVersionLabel;
@property (nonatomic, retain) UILabel *appDeveloperLabel;
@property (nonatomic, retain) UIImageView *appImageView;
@property (nonatomic, retain) UIActivityIndicatorView *appActivityIndicator;
@property (nonatomic, retain) UIProgressView *appProgressView;
- (void)updateFromRep:(YZQueueRep *)rep;
- (YZQueueRep *)rep;
@end