#import "QueueTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "../../AppDelegate.h"

@implementation QueueTableViewCell {
    YZQueueRep *_rep;
    NSString *_imageFromURL;
}
@synthesize appNameLabel;
@synthesize appVersionLabel;
@synthesize appDeveloperLabel;
@synthesize appImageView;
@synthesize appActivityIndicator;
@synthesize appProgressView;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        CGFloat height = 78;

        // App Cell image background
        UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, height+1)];
        background.image = [UIImage imageNamed:@"AppCellBG.png"];

        // App Image
        appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 8, 64, 64)];
        appImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        appImageView.layer.masksToBounds = YES;
        appImageView.layer.cornerRadius = 13.0;

        // App Name
        appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(79, 29, 186, 21)];
        appNameLabel.numberOfLines = 1;
        appNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        appNameLabel.text = @"Grrrr rawr :3";
        appNameLabel.font = [UIFont boldSystemFontOfSize:17.0];
        appNameLabel.autoresizingMask = 
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
            | UIViewAutoresizingFlexibleWidth;
        appNameLabel.backgroundColor = [UIColor clearColor];

        // App Version
        appVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(79, 54, 48, 21)];
        appVersionLabel.text = [NSString stringWithFormat:@"Version: kys"];
        appVersionLabel.font = [UIFont systemFontOfSize:10];
        appVersionLabel.textColor = [UIColor lightGrayColor];
        appVersionLabel.autoresizingMask = 
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
            | UIViewAutoresizingFlexibleWidth;
        appVersionLabel.backgroundColor = [UIColor clearColor];
        [appVersionLabel sizeToFit];

        // App Developer
        appDeveloperLabel = [[UILabel alloc] initWithFrame:CGRectMake(79, 8, 161, 21)];
        appDeveloperLabel.text = @">:3";
        appDeveloperLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        appDeveloperLabel.backgroundColor = [UIColor clearColor];
        appDeveloperLabel.autoresizingMask = 
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin
            | UIViewAutoresizingFlexibleWidth;

        appActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        appActivityIndicator.frame = CGRectMake(290, 29, 20, 20);
        appActivityIndicator.hidesWhenStopped = YES;
        appActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;

        // Progress Bar
        appProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        appProgressView.frame = CGRectMake(270, 35, 40, 20);
        appProgressView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        appProgressView.hidden = YES;

        [self.contentView addSubview:background];
        [self.contentView addSubview:appImageView];
        [self.contentView addSubview:appNameLabel];
        [self.contentView addSubview:appVersionLabel];
        [self.contentView addSubview:appDeveloperLabel];
        [self.contentView addSubview:appActivityIndicator];
        [self.contentView addSubview:appProgressView];

        // change cilcked color
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _rep = nil;
    self.appProgressView.hidden = YES;
    self.appProgressView.progress = 0;
}

- (void)updateFromRep:(YZQueueRep *)rep {
    appNameLabel.text = rep.name;
    appDeveloperLabel.text = rep.developer;
    if (rep.icon == nil) {
        if (rep.iconurl == nil || ![rep.iconurl isEqualToString:_imageFromURL]) {
            appImageView.image = [VAPISS imageFromCache:rep.iconurl];
            if (appImageView.image == nil) {
                [VAPISS getStatic:rep.iconurl completion:^(NSData *data, NSError *error) {
                    if (error == nil) {
                        appImageView.image = [UIImage imageWithData:data];
                        _imageFromURL = rep.iconurl;
                    } else {
                        debugLog(@"Failed to fetch image for %@: %@", rep.bundleID, [error localizedDescription]);
                    }
                }];
            }
        }
    } else {
        appImageView.image = rep.icon;
    }

    appVersionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version", nil), rep.version];
    [appVersionLabel sizeToFit];
    [self setNeedsDisplay];
    _rep = rep;
}

- (YZQueueRep *)rep {
    return _rep;
}

@end