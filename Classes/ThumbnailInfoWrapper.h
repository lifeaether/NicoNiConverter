
#import <Foundation/Foundation.h>


@interface ThumbnailInfoWrapper : NSObject <NSCopying> {
    NSXMLDocument *document;
}

- (id)initWithDocument:(NSXMLDocument *)doc;
+ (id)thumbnailInfoWrapperWithDocument:(NSXMLDocument *)doc;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSURL *thumbnailURL;
@property (nonatomic, readonly) NSString *movieType;

@end
