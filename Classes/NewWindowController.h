
#import <Cocoa/Cocoa.h>

@interface NewWindowController : NSWindowController {
@private
    NSString *identifier;
    NSUInteger selectedConverter;
    NSArrayController *convertController;
    BOOL isEnableConvert;
}
@property (retain) IBOutlet NSArrayController *convertController;

@property NSUInteger selectedConverter;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, setter = setEnableConvert:) BOOL isEnableConvert;

- (IBAction)OK:(id)sender;
- (IBAction)cancel:(id)sender;

@end
