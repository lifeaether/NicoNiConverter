
#import "Item.h"
#import "ThumbnailInfoWrapper.h"

@implementation Item

@synthesize identifier, command, convert, extension, tempFilePath, information, image;
@synthesize message, bytePerSeconds, leftTime;
@synthesize progress;
@synthesize isFinished, isOccursError, isCancelled;

- (id)initWithIdentifier:(NSString *)anID {
    self = [super init];
    if ( self ) {
        [self setIdentifier:anID];
        isFinished = NO;
        isOccursError = NO;
        isCancelled = NO;
    }
    return self;
}

- (void)dealloc {
    [identifier release];
    [information release];
    [extension release];
    [convert release];
    [tempFilePath release];
    [command release];
    [image release];
    [super dealloc];
}

- (NSString *)filename {
    NSString *tmp = [[information title] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    if ( [extension length] == 0 ) {
        return [tmp stringByAppendingPathExtension:[information movieType]];
    } else {
        return [tmp stringByAppendingPathExtension:extension];
    }
}

@end
