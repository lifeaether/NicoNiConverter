
#import <Cocoa/Cocoa.h>
#import "NewMultipleController.h"
#import "NewWindowController.h"

@interface NicoNiConverterAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet NSArrayController *itemController;
    NewMultipleController *multipleWindowController;
    NewWindowController *newWindowController;
    
    NSOperationQueue *loadInfoQueue;
    NSOperationQueue *loadVideoQueue;
    NSOperationQueue *convertVideoQueue;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) IBOutlet NSArrayController *itemController;
@property (retain) IBOutlet NewMultipleController *multipleWindowController;
@property (retain) IBOutlet NewWindowController *newWindowController;

- (void)openURL:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;

- (void)newSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)newMultipleSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (IBAction)remove:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)stopAll:(id)sender;
- (IBAction)clearAll:(id)sender;
- (IBAction)restart:(id)sender;
- (IBAction)restartAll:(id)sender;

- (IBAction)showHelp:(id)sender;
- (IBAction)open:(id)sender;

- (void)openWithString:(NSString *)string;


- (void)addItemWithID:(NSString *)anID convertIndex:(NSUInteger)idx;
- (void)addConvertItemWithID:(NSString *)anID converterIndex:(NSUInteger)idx;
- (void)beginItem:(id)item;
- (void)moveItem:(id)item;

@end
