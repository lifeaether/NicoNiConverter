
#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSWindowController {
@private
    
    NSToolbarItem *generalItem;
    NSToolbarItem *convertItem;
    NSToolbar *toolBar;
    NSTabView *tabView;
    NSArrayController *settingController;
    NSPopUpButton *directoryPopUpButton;
}
@property (retain) IBOutlet NSPopUpButton *directoryPopUpButton;
@property (retain) IBOutlet NSToolbarItem *generalItem;
@property (retain) IBOutlet NSToolbarItem *convertItem;
@property (retain) IBOutlet NSToolbar *toolBar;
@property (retain) IBOutlet NSTabView *tabView;
@property (retain) IBOutlet NSArrayController *settingController;
- (IBAction)setTab:(id)sender;
- (IBAction)setDirectory:(id)sender;

@end
