#import "KSCrashReportSinkVAPI.h"

#import "../../KSCrash/Recording/Tools/KSCrashCallCompletion.h"
#import "../../KSCrash/Recording/Tools/NSError+SimpleConstructor.h"
#import "../../KSCrash/Reporting/Filters/KSCrashReportFilterGZip.h"
#import "../../KSCrash/Reporting/Filters/KSCrashReportFilterJSON.h"
#import "../../KSCrash/Recording/Tools/KSJSONCodecObjC.h"
#import "../../BBHTTP/BBHTTP.h"
#import "../../BBHTTP/BBHTTPRequest+Convenience.h"
#import "VAPIHelper.h"
#import "../ProtoStack.h"

//#define KSLogger_LocalLevel TRACE
#import "KSLogger.h"

@implementation KSCrashReportSinkVAPI

+ (KSCrashReportSinkVAPI*) sink
{
    return [[self alloc] init];
}

- (id <KSCrashReportFilter>) defaultCrashReportFilterSet
{
    return [KSCrashReportFilterPipeline filterWithFilters:@[ 
        [KSCrashReportFilterJSONEncode filterWithOptions:KSJSONEncodeOptionSorted | KSJSONEncodeOptionPretty],
        [KSCrashReportFilterGZipCompress filterWithCompressionLevel:-1],
        self,
    ], nil];
}

- (void)filterReports:(NSArray *)reports onCompletion:(KSCrashReportFilterCompletion)onCompletion {
    debugLog(@"Reporting %d crashes", (int)[reports count]);
    NSString *url = [NSString stringWithFormat:@"%@crash", [VAPIHelper getApiBaseURL]];
    debugLog(@"URL: %@", url);
    NSData *data = (__bridge NSData*)nsencode(reports, CrashRequest);
    if (data == nil) {
        debugLog(@"Could not encode crash report!");
        kscrash_i_callCompletion(onCompletion, reports, NO, [NSError errorWithDomain:[[self class] description] code:0 description:@"Could not encode crash report!"]);
        return;
    }
    BBHTTPRequest *request = [BBHTTPRequest createResource:url withData:data contentType:@"application/x-protobuf"];
    [request setHeaders:[VAPIHelper getHeaders]];
    BBHTTPExecutor *executor = [BBHTTPExecutor sharedExecutor];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    request.finishBlock = ^(BBHTTPRequest *request) {
        debugLog(@"Request finished");
        if (request.cancelled) {
            kscrash_i_callCompletion(onCompletion, reports, NO, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]);
        }
        else if ([request hasSuccessfulResponse]) {
            kscrash_i_callCompletion(onCompletion, reports, YES, nil);
        } else {
            kscrash_i_callCompletion(onCompletion, reports, NO, request.error);
        }
        dispatch_semaphore_signal(semaphore);
    };
    request.kscrash = true;
    [executor executeRequest:request];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
