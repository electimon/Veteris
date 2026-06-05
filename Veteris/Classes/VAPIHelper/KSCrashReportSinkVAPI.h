#import "../../KSCrash//Reporting/Filters/KSCrashReportFilter.h"

@interface KSCrashReportSinkVAPI : NSObject <KSCrashReportFilter>

/** Constructor.
 *
 * @param url The URL to connect to.
 */
+ (KSCrashReportSinkVAPI*) sink;

- (id <KSCrashReportFilter>) defaultCrashReportFilterSet;

@end
