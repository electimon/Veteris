#include <pb.h>
#include <pb_decode.h>
#include <pb_encode.h>
#import "../Protos/App.pb.h"
#import "../Protos/Categories.pb.h"
#import "../Protos/News.pb.h"
#import "../Protos/Suggestions.pb.h"
#import "../Protos/VTableResponse.pb.h"
#import "../Protos/Update.pb.h"
#import "../Protos/CrashReq.pb.h"
#import "Protos/Application.h"
#import "Protos/Category.h"
#import "Protos/News.h"
#import "Protos/Suggestion.h"
#import "Protos/Version.h"
#import "Protos/Update.h"
#import "VAPIHelper/VAPIHelper.h"

typedef enum {
    VTableResponse = 0,
    VTableRequest = 1,
    CategoriesResponse = 2,
    CategoriesRequest = 3,
    SuggestionsResponse = 4,
    SuggestionsRequest = 5,
    AppResponse = 6,
    AppRequest = 7,
    NewsResponse = 8,
    NewsRequest = 9,
    UpdateResponse = 10,
    CrashRequest = 11,
} ProtoType;

void* decode(const void* data, size_t data_len, ProtoType type);
void* nsencode(id obj, ProtoType type);

