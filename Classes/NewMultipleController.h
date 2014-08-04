
#import <Cocoa/Cocoa.h>


@interface NewMultipleController : NSWindowController {
@private
    NSString *message;
    BOOL isLoading;
    NSUInteger defaultConverterIndex;
    NSArrayController *itemController;
    
    NSOperationQueue *loadQueue;
}

@property (nonatomic, copy) NSString *message;
@property (nonatomic) NSUInteger defaultConverterIndex;
@property (nonatomic, setter=setLoading:) BOOL isLoading;
@property (retain) IBOutlet NSArrayController *itemController;

@property (nonatomic, retain, readonly) NSArray *items;

// only http protocols.
- (void)loadURL:(NSURL *)url;
- (void)loadMylist:(NSURL *)url;
- (IBAction)cancel:(id)sender;
- (IBAction)OK:(id)sender;

@end
