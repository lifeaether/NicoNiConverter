
#import "ThumbnailInfoWrapper.h"
#import "NSXMLNode+XPathAddition.h"

@implementation ThumbnailInfoWrapper

+ (id)thumbnailInfoWrapperWithDocument:(NSXMLDocument *)doc {
    return [[[self alloc] initWithDocument:doc] autorelease];
}

- (id)initWithDocument:(NSXMLDocument *)doc {
    self = [super init];
    if ( self ) {
        document = [doc copy];
    }
    return self;
}

- (void)dealloc {
    [document release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithDocument:document];
}


- (NSString *)identifier {
    return [document stringValueForXPath:@"nicovideo_thumb_response/thumb/video_id" error:nil];
}

- (NSString *)title {
    return [document stringValueForXPath:@"nicovideo_thumb_response/thumb/title" error:nil];
}

- (NSURL *)thumbnailURL {
    return [NSURL URLWithString:[document stringValueForXPath:@"nicovideo_thumb_response/thumb/thumbnail_url" error:nil]];
}

- (NSString *)movieType {
    return [document stringValueForXPath:@"nicovideo_thumb_response/thumb/movie_type" error:nil];
}

@end
