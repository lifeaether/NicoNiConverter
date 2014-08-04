
#import "PreferencesController.h"
#import "Constants.h"

static NSString * const kGeneralTab = @"General";
static NSString * const kConvertTab = @"Convert";

static NSString * const kObserveNameKey = @"arrangedObjects.name";
static NSString * const kObserveCommandKey = @"arrangedObjects.command";
static NSString * const kObserveExtensionKey = @"arrangedObjects.extension";

static const CGFloat kGeneralHeight = 200;
static const CGFloat kConvertHeight = 470;

@implementation PreferencesController
@synthesize directoryPopUpButton;
@synthesize generalItem;
@synthesize convertItem;
@synthesize toolBar;
@synthesize tabView;
@synthesize settingController;


- (id)init {
    return [self initWithWindowNibName:@"Preferences"];
}

- (id)initWithWindow:(NSWindow *)window {
    if ((self = [super initWithWindow:window])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    [[settingController content] removeObserver:self forKeyPath:kObserveNameKey];
    [[settingController content] removeObserver:self forKeyPath:kObserveCommandKey];
    [[settingController content] removeObserver:self forKeyPath:kObserveExtensionKey];
    [generalItem release];
    [convertItem release];
    [toolBar release];
    [tabView release];
    [settingController release];
    [directoryPopUpButton release];
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)awakeFromNib {
    [toolBar setSelectedItemIdentifier:kGeneralTab];
    
    
    if ( [[settingController content] count] == 0 ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *settings = [defaults mutableArrayValueForKey:kPrefFFMpegConvertSettingsKey];
        [settingController addObjects:settings];
        [settingController setSelectionIndex:0];
        
        [settingController addObserver:self forKeyPath:kObserveNameKey options:NSKeyValueObservingOptionNew context:nil];
        [settingController addObserver:self forKeyPath:kObserveCommandKey options:NSKeyValueObservingOptionNew context:nil];
        [settingController addObserver:self forKeyPath:kObserveExtensionKey options:NSKeyValueObservingOptionNew context:nil];
        
        NSString *dirPath = [defaults valueForKey:kPrefDownloadDirectoryKey];
        NSString *disp = [[NSFileManager defaultManager] displayNameAtPath:dirPath];
        [directoryPopUpButton addItemWithTitle:[disp lastPathComponent]];

        [[directoryPopUpButton menu] addItem:[NSMenuItem separatorItem]];
        [directoryPopUpButton addItemWithTitle:NSLocalizedString(@"others...", nil)];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[settingController content] forKey:kPrefFFMpegConvertSettingsKey];
}

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:kGeneralTab, kConvertTab, nil];
}

- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar
{
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemId willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
    if ( [itemId isEqualToString:kGeneralTab] ) return generalItem;
    if ( [itemId isEqualToString:kConvertTab] ) return convertItem;
    return nil;
}

- (IBAction)setTab:(id)sender {
    NSRect r = [[self window] frame];
    float h = r.size.height;
    if ( [[sender itemIdentifier] isEqualToString:kGeneralTab] ) h = kGeneralHeight;
    if ( [[sender itemIdentifier] isEqualToString:kConvertTab] ) h = kConvertHeight;
    float dh = h - r.size.height;
    r.origin.y -= dh;
    r.size.height = h;
    [[self window] setFrame:r display:YES animate:YES];
    [tabView selectTabViewItemWithIdentifier:[sender itemIdentifier]];
}

- (IBAction)setDirectory:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ( [sender selectedItem] == [directoryPopUpButton lastItem] ) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanChooseFiles:NO];
        [panel setCanChooseDirectories:YES];
        [panel setCanCreateDirectories:YES];
        [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
            if ( result == NSFileHandlingPanelOKButton ) {
                NSString *dirPath = [[panel directoryURL] path];
                NSString *disp = [[NSFileManager defaultManager] displayNameAtPath:dirPath];
                [[directoryPopUpButton itemAtIndex:0] setTitle:[disp lastPathComponent]];
                [defaults setValue:dirPath forKey:kPrefDownloadDirectoryKey];
                [defaults synchronize];
            }
        }];
    }
    [directoryPopUpButton selectItemAtIndex:0];
}

@end
