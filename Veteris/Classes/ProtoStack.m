#include "ProtoStack.h"
#include <pb.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define setDecFS(...) __VA_ARGS__.funcs.decode = &decode_string

static char __[] = { 
    'u' ^ 0x12, 'w' ^ 0x12, 'u' ^ 0x12, 'o' ^ 0x12, 'w' ^ 0x12,
    'o' ^ 0x12, 'r' ^ 0x12, 'a' ^ 0x12, 'w' ^ 0x12, 'r' ^ 0x12,
    'm' ^ 0x12, 'e' ^ 0x12, 'w' ^ 0x12, 'n' ^ 0x12, 'y' ^ 0x12,
    'a' ^ 0x12, 'l' ^ 0x12, 'e' ^ 0x12, 's' ^ 0x12, 's' ^ 0x12,
    't' ^ 0x12, 'h' ^ 0x12, 'a' ^ 0x12, 'n' ^ 0x12, 't' ^ 0x12,
    'h' ^ 0x12, 'r' ^ 0x12, 'e' ^ 0x12, 'e' ^ 0x12, '\0'
};

static bool decode_string(pb_istream_t *stream, const pb_field_t *field, void **arg) {
    size_t string_size = stream->bytes_left + 1;
    // debugLog(@"String size: %zu", string_size);
    char **str = (char **)arg;
    *str = (char *)malloc(string_size);
    if (*str == NULL) {
        return false;
    }
    if (!pb_read(stream, (pb_byte_t *)(*str), string_size - 1)) { // Read string_size - 1 to leave room for '\0'
        free(*str);
        debugLog(@"Failed to read string data");
        return false;
    }
    (*str)[string_size - 1] = '\0';
    return true;
}

static bool decode_versions(pb_istream_t *stream, const pb_field_t *field, void **arg) {
    VersionMsg version = VersionMsg_init_zero;
    setDecFS(version.version);
    setDecFS(version.fileName);
    setDecFS(version.minVersion);
    if (!pb_decode(stream, VersionMsg_fields, &version)) {
        const char *error = PB_GET_ERROR(stream);
        debugLog(@"Error decoding VersionMsg: %s — freeing partial allocs", error);
        free(version.version.arg);
        free(version.fileName.arg);
        free(version.minVersion.arg);
        return false;
    }
    Version *versionObj = [[Version alloc] initFromVersionProto:version];
    NSMutableArray *versions = (__bridge NSMutableArray *)(*arg);
    if (versions == nil) {
        versions = [NSMutableArray array];
    }
    [versions addObject:versionObj];
    *arg = (__bridge_retained void *)versions;
    free(version.version.arg);
    free(version.fileName.arg);
    free(version.minVersion.arg);
    return true;
}

static bool decode_suggestions(pb_istream_t *stream, const pb_field_t *field, void **arg) {
    SuggestionMsg suggestion = SuggestionMsg_init_zero;
    setDecFS(suggestion.name);
    setDecFS(suggestion.bundleid);
    if (!pb_decode(stream, SuggestionMsg_fields, &suggestion)) {
        const char *error = PB_GET_ERROR(stream);
        debugLog(@"Error decoding SuggestionMsg: %s — freeing partial allocs", error);
        free(suggestion.name.arg);
        free(suggestion.bundleid.arg);
        return false;
    }
    NSMutableArray *suggestionsArray = (__bridge NSMutableArray *)(*arg);
    if (suggestionsArray == nil) {
        suggestionsArray = [NSMutableArray array];
    }
    [suggestionsArray addObject:[[Suggestion alloc] initFromSuggestionProto:suggestion]];
    *arg = (__bridge_retained void *)suggestionsArray;
    free(suggestion.name.arg);
    free(suggestion.bundleid.arg);
    return true;
}

static bool decode_vtable_entries(pb_istream_t *stream, const pb_field_t *field, void **arg) {
    VTableEntryMsg entry = VTableEntryMsg_init_zero;
    setDecFS(entry.name);
    setDecFS(entry.developer);
    setDecFS(entry.bundleid);
    setDecFS(entry.version);
    setDecFS(entry.iconurl);
    if (!pb_decode(stream, VTableEntryMsg_fields, &entry)) {
        const char *error = PB_GET_ERROR(stream);
        debugLog(@"Error decoding VTableEntryMsg: %s — freeing partial allocs", error);
        free(entry.name.arg);
        free(entry.developer.arg);
        free(entry.bundleid.arg);
        free(entry.version.arg);
        free(entry.iconurl.arg);
        return false;
    }
    NSMutableArray *entries = (__bridge NSMutableArray *)(*arg);
    if (entries == nil) {
        entries = [NSMutableArray array];
    }
    [entries addObject:[[Application alloc] initFromVTableEntryProto:entry]];
    *arg = (__bridge_retained void *)entries;
    free(entry.name.arg);
    free(entry.developer.arg);
    free(entry.bundleid.arg);
    free(entry.version.arg);
    free(entry.iconurl.arg);
    return true;
}

static bool decode_categories_entries(pb_istream_t *stream, const pb_field_t *field, void **arg) {
    CategoryMsg entry = CategoryMsg_init_zero;
    setDecFS(entry.id);
    setDecFS(entry.name);
    if (!pb_decode(stream, CategoryMsg_fields, &entry)) {
        const char *error = PB_GET_ERROR(stream);
        debugLog(@"Error decoding CategoryMsg: %s — freeing partial allocs", error);
        free(entry.id.arg);
        free(entry.name.arg);
        return false;
    }
    NSMutableArray *entries = (__bridge NSMutableArray *)(*arg);
    if (entries == nil) {
        entries = [NSMutableArray array];
    }
    [entries addObject:[[CategoryProt alloc] initFromCategoryProto:entry]];
    *arg = (__bridge_retained void *)entries;
    free(entry.id.arg);
    free(entry.name.arg);
    return true;
}

static bool decode_news_entries(pb_istream_t *stream, const pb_field_t *field, void **arg) {
    NewsEntry entry = NewsEntry_init_zero;
    setDecFS(entry.author);
    setDecFS(entry.title);
    setDecFS(entry.body);
    setDecFS(entry.date);
    setDecFS(entry.link);
    if (!pb_decode(stream, NewsEntry_fields, &entry)) {
        const char *error = PB_GET_ERROR(stream);
        debugLog(@"Error decoding NewsEntry: %s — freeing partial allocs", error);
        free(entry.author.arg);
        free(entry.title.arg);
        free(entry.body.arg);
        free(entry.date.arg);
        free(entry.link.arg);
        return false;
    }
    NSMutableArray *entries = (__bridge NSMutableArray *)(*arg);
    if (entries == nil) {
        entries = [NSMutableArray array];
    }
    [entries addObject:[[NewsPost alloc] initFromNewsEntryProto:entry]];
    *arg = (__bridge_retained void *)entries;
    free(entry.author.arg);
    free(entry.title.arg);
    free(entry.body.arg);
    free(entry.date.arg);
    free(entry.link.arg);
    return true;
}

static inline uint8_t* _(const uint8_t* data, size_t data_len, const uint8_t* _____) {
    if (data == NULL || _____ == NULL || data_len == 0) {
        return NULL;
    }
    uint8_t* ____ = (uint8_t*)malloc(data_len);
    if (____ == NULL) {
        return NULL;
    }
    size_t _______ = strlen((const char *)_____);
    for (size_t i = 0; i < data_len; i++) {
        ____[i] = data[i] ^ _____[i % _______];
    }
    return ____;
}

void ___(uint8_t* dest, const char* src, size_t len) {
    for (size_t i = 0; i < len; i++) {
        dest[i] = src[i] ^ 0x12;
    }
    dest[len] = '\0';
}

void* decode(const void* data, size_t data_len, ProtoType type) {
    if (data == NULL) {
        debugLog(@"Data is nil");
        return NULL;
    }
    uint8_t decoded_key[sizeof(__)];
    ___(decoded_key, __, sizeof(__) - 1);
    uint8_t *____ = _(data, data_len, decoded_key);
    if (____ == NULL) {
        debugLog(@"Failed to decrypt data");
        return NULL;
    }
    debugLog(@"Decoding data of type %d", type);
    pb_istream_t stream = pb_istream_from_buffer(____, data_len);
    switch (type) {
        case AppResponse: {
            AppMsg app = AppMsg_init_zero;
            setDecFS(app.name);
            setDecFS(app.developer);
            setDecFS(app.bundleid);
            setDecFS(app.iconurl);
            setDecFS(app.description);
            app.versions.funcs.decode = &decode_versions;
            bool success = pb_decode(&stream, AppMsg_fields, &app);
            if (!success) {
                const char *error = PB_GET_ERROR(&stream);
                debugLog(@"Error decoding AppMsg: %s — freeing partial allocs", error);
                free(app.name.arg);
                free(app.developer.arg);
                free(app.bundleid.arg);
                free(app.iconurl.arg);
                free(app.description.arg);
                return NULL;
            }
            Application *application = [[Application alloc] initFromAppProto:app];
            return (__bridge_retained void *)application;
        }
        case SuggestionsResponse: {
            debugLog(@"SuggestionsResponse");
            SuggestionsMsg suggestions = SuggestionsMsg_init_zero;
            suggestions.suggestions.funcs.decode = &decode_suggestions;
            bool success = pb_decode(&stream, SuggestionsMsg_fields, &suggestions);
            if (!success) {
                const char *error = PB_GET_ERROR(&stream);
                debugLog(@"Error decoding SuggestionsMsg: %s", error);
                return nil;
            }
            return suggestions.suggestions.arg;
        }
        case VTableResponse: {
            VTableResponseMsg vtable = VTableResponseMsg_init_zero;
            vtable.entries.funcs.decode = &decode_vtable_entries;
            bool success = pb_decode_ex(&stream, VTableResponseMsg_fields, &vtable, PB_DECODE_NOINIT);
            if (!success) {
                const char *error = PB_GET_ERROR(&stream);
                debugLog(@"Error decoding VTableResponseMsg: %s", error);
                return nil;
            }
            return vtable.entries.arg;
        }
        case CategoriesResponse: {
            CategoriesMsg categories = CategoriesMsg_init_zero;
            categories.categories.funcs.decode = &decode_categories_entries;
            bool success = pb_decode(&stream, CategoriesMsg_fields, &categories);
            if (!success) {
                const char *error = PB_GET_ERROR(&stream);
                debugLog(@"Error decoding CategoriesMsg: %s", error);
                return nil;
            }
            return categories.categories.arg;
        }
        case NewsResponse: {
            NewsMsg news = NewsMsg_init_zero;
            news.news.funcs.decode = &decode_news_entries;
            bool success = pb_decode(&stream, NewsMsg_fields, &news);
            if (!success) {
                const char *error = PB_GET_ERROR(&stream);
                debugLog(@"Error decoding NewsMsg: %s", error);
                return nil;
            }
            return news.news.arg;
        }
        case UpdateResponse: {
            UpdateMsg update = UpdateMsg_init_zero;
            setDecFS(update.version);
            setDecFS(update.changelog);
            bool success = pb_decode(&stream, UpdateMsg_fields, &update);
            if (!success) {
                const char *error = PB_GET_ERROR(&stream);
                debugLog(@"Error decoding UpdateMsg: %s — freeing partial allocs", error);
                free(update.version.arg);
                free(update.changelog.arg);
                return nil;
            }
            Update *updateObj = [[Update alloc] initFromUpdateProto:update];
            return (__bridge_retained void *)updateObj;
        }
        default: {
            return nil;
            break;
        }
    }
}

static bool encode_bytes(pb_ostream_t *stream, const pb_field_t *field, void * const *arg) {
    NSData *data = (__bridge NSData *)(*arg);
    if (!pb_encode_tag_for_field(stream, field)) {
        return false;
    }
    if (!pb_encode_string(stream, data.bytes, data.length)) {
        return false;
    }
    return true;
}

static bool encode_crash(pb_ostream_t *stream, const pb_field_t *field, void * const *arg) {
    NSArray *crashes = (__bridge NSArray *)(*arg);
    for (NSData *crashData in crashes) {
        CrashReportEntry entry = CrashReportEntry_init_zero;
        entry.data.funcs.encode = &encode_bytes;
        entry.data.arg = (__bridge void *)(crashData);
        if (!pb_encode_tag_for_field(stream, field)) {
            return false;
        }
        if (!pb_encode_submessage(stream, CrashReportEntry_fields, &entry)) {
            return false;
        }
    }
    return true;
}

void* nsencode(id obj, ProtoType type) {
    switch (type) {
        case CrashRequest: {
            // Assume input is an NSArray of NSData containing gzipped crash reports
            NSArray *crashes = (NSArray *)obj;
            CrashReportMsg crash = CrashReportMsg_init_zero;
            crash.entries.funcs.encode = &encode_crash;
            crash.entries.arg = (__bridge void *)crashes;
            pb_ostream_t sizingStream = PB_OSTREAM_SIZING;
            if (!pb_encode(&sizingStream, CrashReportMsg_fields, &crash)) {
                debugLog(@"Failed to calculate encoding size: %s", PB_GET_ERROR(&sizingStream));
                return NULL;
            }
            size_t bufferSize = sizingStream.bytes_written;
            NSMutableData *buffer = [NSMutableData dataWithLength:bufferSize];
            pb_ostream_t stream = pb_ostream_from_buffer(buffer.mutableBytes, bufferSize);
            if (!pb_encode(&stream, CrashReportMsg_fields, &crash)) {
                NSLog(@"Failed to encode CrashReportMsg: %s", PB_GET_ERROR(&stream));
                return NULL;
            }
            return (__bridge void*)[NSData dataWithBytes:buffer.bytes length:stream.bytes_written];
        }
        default: {
            return NULL;
        }
    }
}
