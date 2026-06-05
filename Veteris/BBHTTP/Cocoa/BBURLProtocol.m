#import "BBURLProtocol.h"
#import "../BBHTTPExecutor.h"
#import "../BBHTTPRequest+Convenience.h"
#import "../Internal/BBHTTPRequest+PrivateInterface.h"

@implementation BBURLProtocol {
    BBHTTPRequest *bbRequest;
}

static BBHTTPExecutor *executor = nil;

- (void)startLoading {
    if (executor == nil) {
        executor = [[BBHTTPExecutor alloc] initWithId:@"BBURLProtocol"];
        executor.maxParallelRequests = 3;
    }
    bbRequest = [[BBHTTPRequest alloc] initWithTarget:[self.request.URL.absoluteString stringByReplacingOccurrencesOfString:@"bbhttps" withString:@"https"] andVerb:@"GET"];
    [bbRequest setHeaders:self.request.allHTTPHeaderFields];
    __weak __typeof__(self) weakSelf = self;
    bbRequest.initialResponseBlock = ^(NSUInteger statusCode, NSDictionary *headers) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:strongSelf.request.URL statusCode:statusCode HTTPVersion:@"1.1" headerFields:headers];
            [strongSelf.client URLProtocol:strongSelf didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        }
    };
    bbRequest.finishBlock = ^(BBHTTPRequest *_request) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (_request.cancelled) {
                [strongSelf.client URLProtocol:strongSelf didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]];
                return;
            }
            if ([_request hasSuccessfulResponse]) {
                [strongSelf.client URLProtocolDidFinishLoading:strongSelf];
            } else {
                [strongSelf.client URLProtocol:strongSelf didFailWithError:_request.error];
            }
        }
    };
    [bbRequest downloadToUser:^(uint8_t *data, NSUInteger length) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf.client URLProtocol:strongSelf didLoadData:[NSData dataWithBytes:data length:length]];
        }
    }];
    [executor executeRequest:bbRequest];
}

- (void)stopLoading {
    if (bbRequest == nil) {
        return;
    }
    [bbRequest cancel];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // match bbhttps scheme
    if ([request.URL.scheme isEqualToString:@"bbhttps"]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b; {
    bool equal = true;
    if (![a.URL isEqual:b.URL]) {
        equal = false;
    }
    return equal;
}

- (void)dealloc {
    if (bbRequest == nil) {
        return;
    }
    [bbRequest cancel];
}
@end