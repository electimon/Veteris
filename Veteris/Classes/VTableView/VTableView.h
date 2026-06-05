#import <UIKit/UIKit.h>
#import "../../AppDelegate.h"
#import "../Protos/Application.h"

@interface VTableView : UITableViewController<UIAlertViewDelegate>
- (void)initialize:(NSString *)endpoint;
- (void)initialize:(NSString *)endpoint skipIndicator:(BOOL)skipIndicator;
@property (strong, nonatomic) NSArray *applications;
@end
