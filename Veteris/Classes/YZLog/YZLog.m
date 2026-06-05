#import "YZLog.h"
#import "../../AppDelegate.h"
#import "../DebugTextView/DebugTextView.h"

@implementation YZLog

#ifdef DEBUG
+ (void)debugLog:(NSString *)location message:(NSString *)message {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *debugMsg = [NSString stringWithFormat:@"%@: %@\n", location, message];
    NSLog(@"%@", debugMsg);
    [[DebugTextView fromWindow:delegate.window] log:debugMsg]; 
}
#endif

const char *base36_alphabet = "0123456789abcdefghijklmnopqrstuvwxyz";

// Function to encode a string into Base36
NSString* base36_encode(const char *input) {
    uint64_t value = 0;
    size_t len = strlen(input);

    // Convert string to a large integer (big-endian)
    for (size_t i = 0; i < len; i++) {
        value = value * 256 + (unsigned char)input[i];
    }

    // Prepare an array to hold the encoded Base36 string
    char encoded[100];
    int index = 0;

    // Convert the integer to a Base36 string
    do {
        encoded[index++] = base36_alphabet[value % 36];
        value /= 36;
    } while (value > 0);

    encoded[index] = '\0';

    // Reverse the string to get the correct order
    for (int i = 0, j = index - 1; i < j; i++, j--) {
        char temp = encoded[i];
        encoded[i] = encoded[j];
        encoded[j] = temp;
    }

    // Convert the char array to an NSString and return it
    return [NSString stringWithUTF8String:encoded];
}
@end