#import "KSCrashInstallationVAPI.h"
#import "../../KSCrash/Installations/KSCrashInstallation+Private.h"
#import "../../KSCrash/Recording/Tools/KSSingleton.h"
#import "KSCrashReportSinkVAPI.h"
#import "../YZLog/YZLog.h"

@implementation KSCrashInstallationVAPI

IMPLEMENT_EXCLUSIVE_SHARED_INSTANCE(KSCrashInstallationVAPI)

- (id) init
{
    if (self = [super initWithRequiredProperties:nil]) {
        return self;
    }
    return nil;
}

- (id<KSCrashReportFilter>) sink
{
    debugLog(@"got sink!");
    KSCrashReportSinkVAPI* sink = [KSCrashReportSinkVAPI sink];
    return [KSCrashReportFilterPipeline filterWithFilters:[sink defaultCrashReportFilterSet], nil];
}

@end
