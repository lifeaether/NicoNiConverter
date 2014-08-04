
#import "InformationLoader.h"
#import "Constants.h"
#import "NSXMLNode+XPathAddition.h"
#import "ThumbnailInfoWrapper.h"

@implementation InformationLoader

+ (id)informationLoaderWithItem:(Item *)anItem {
    return [[[self alloc] initWithItem:anItem] autorelease];
}

- (id)initWithItem:(Item *)anItem {
    self = [super init];
    if ( self ) {
        item = [anItem retain];
    }
    return self;
}

- (void)dealloc {
    [item release];
    [super dealloc];
}

- (BOOL)isCancelled {
    return [item isCancelled];
}

- (void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [item setMessage:NSLocalizedString( @"Loading thumbnail information...", nil )];
    
    NSString *URLString = [kURLNicoVideoAPIGetThumbInfo stringByAppendingString:[item identifier]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ( ! data ) {
        NSLog( @"%@", error );
        [item setMessage:NSLocalizedString( @"Failed to load thumbnail info.", nil )];
        goto ERROR;
    }
    
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentValidate error:&error] autorelease];
    if ( ! doc ) goto ERROR;
    
    NSString *status = [doc stringValueForXPath:@"nicovideo_thumb_response/@status" error:&error];
    if ( ! [status isEqualToString:@"ok"] ) {
        [item setMessage:NSLocalizedString( @"Not found or Invalid ID.", nil )];
        goto ERROR;
    }
    
    id wrapper = [ThumbnailInfoWrapper thumbnailInfoWrapperWithDocument:doc];
    [item setInformation:wrapper];
    
    request = [NSURLRequest requestWithURL:[wrapper thumbnailURL]];
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ( ! data ) goto FINISH;

    NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
    [item setImage:image];

    [item setMessage:NSLocalizedString( @"Loaded Thumbnail information.", nil )];
    goto FINISH;
ERROR:
    [item setOccursError:YES];
    NSLog( @"%@", error );
FINISH:
    [pool drain];
}

@end
