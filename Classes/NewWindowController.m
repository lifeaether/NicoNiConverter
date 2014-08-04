
#import "NewWindowController.h"
#import "Constants.h"

@implementation NewWindowController

static NSString * const kEnableConvertKey = @"isEnableConvert";

@synthesize convertController, isEnableConvert;
@synthesize selectedConverter, identifier;

- (id)init {
    return [self initWithWindowNibName:@"NewWindow"];
}

- (id)initWithWindow:(NSWindow *)window {
    if ((self = [super initWithWindow:window])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    [identifier release];
    [convertController release];
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)OK:(id)sender {
    [[self window] close];
    [NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (IBAction)cancel:(id)sender {
    [[self window] close];
    [NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (IBAction)showWindow:(id)sender {
    id delegate = [NSApp delegate];
    NSWindow *modal = [delegate window];
    [NSApp beginSheet:[self window]
       modalForWindow:modal
        modalDelegate:delegate
       didEndSelector:@selector(newSheetDidEnd:returnCode:contextInfo:)
          contextInfo:self];

    [self setSelectedConverter:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ( [[defaults valueForKey:kPrefFFMpegLaunchPathKey] length] > 0 ) {
        NSArray *converters = [defaults mutableArrayValueForKey:kPrefFFMpegConvertSettingsKey];
        [convertController removeObjects:[convertController arrangedObjects]];
        [convertController addObjects:converters];
        [self willChangeValueForKey:kEnableConvertKey];
        [self setEnableConvert:YES];
        [self didChangeValueForKey:kEnableConvertKey];
    } else {
        [self willChangeValueForKey:kEnableConvertKey];
        [self setEnableConvert:NO];
        [self didChangeValueForKey:kEnableConvertKey];
    }
}

@end
