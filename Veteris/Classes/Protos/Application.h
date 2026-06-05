#import "../../Protos/App.pb.h"
#import "../Protos/VTableResponse.pb.h"

@interface Application : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *developer;
@property (nonatomic, strong) NSString *bundleid;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *requiredOS;
@property (nonatomic, strong) NSString *app_description;
@property (nonatomic, strong) NSMutableArray *versions;
@property (nonatomic, strong) NSString *version; // Latest version
@property (nonatomic, strong) NSString *iconurl;
@property (nonatomic, strong) UIImage *icon;
@property bool nilIcon;
// VTableEntries are missing rich metadata like descriptions
@property (nonatomic) bool isVTableEntry;

- (Application *)initFromAppProto:(AppMsg)appProto;
- (Application *)initFromVTableEntryProto:(VTableEntryMsg)entry;
- (void)doGetIcon;
@end