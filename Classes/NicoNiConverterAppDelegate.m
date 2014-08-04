
#import "NicoNiConverterAppDelegate.h"
#import "Constants.h"
#import "Item.h"
#import "InformationLoader.h"
#import "MovieLoader.h"
#import "MovieConverter.h"

@implementation NicoNiConverterAppDelegate

@synthesize window;
@synthesize itemController;
@synthesize multipleWindowController;
@synthesize newWindowController;

- (id)init {
    self = [super init];
    if ( self ) {
        loadInfoQueue = [[NSOperationQueue alloc] init];
        loadVideoQueue = [[NSOperationQueue alloc] init];
        convertVideoQueue = [[NSOperationQueue alloc] init];
        [loadInfoQueue setMaxConcurrentOperationCount:3];
        [loadVideoQueue setMaxConcurrentOperationCount:1];
        [convertVideoQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)dealloc {
    [itemController release];
    [loadInfoQueue release];
    [loadVideoQueue release];
    [convertVideoQueue release];
    [multipleWindowController release];
    [newWindowController release];
    [super dealloc];
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
	[window makeKeyAndOrderFront:self];
	return YES;
}

- (void)openURL:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error
{
	[self openWithString:[pboard stringForType:NSStringPboardType]];
}

- (IBAction)showHelp:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kHelpURL]];
}

- (IBAction)open:(id)sender
{
	[self openWithString:@""];
}

- (void)openWithString:(NSString *)string
{
    [newWindowController setIdentifier:string];
    [newWindowController showWindow:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [NSApp setServicesProvider:self];
    
    NSString *path = AppTemporaryDirectory();
	NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ( [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error] ) {
        NSLog( @"App temporary directory is created. %@", path );
    } else {
        NSLog( @"%@", error );
        NSLog( @"Failed to create temporary directory." );
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dirPath = [defaults valueForKey:kPrefDownloadDirectoryKey];
    if ( ! dirPath ) {
        dirPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"];
        [defaults setValue:dirPath forKey:kPrefDownloadDirectoryKey];
    }
    if ( [defaults valueForKey:kPrefFFMpegConvertSettingsKey] == nil ) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"jp.lifeaether.NicoNiConverter" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        [defaults setValue:[dict valueForKey:kPrefFFMpegConvertSettingsKey] forKey:kPrefFFMpegConvertSettingsKey];
        NSLog( @"kPrefFFMpegConcertSetting set by App." );
    }
}

// pass escaped string.
static BOOL moveFile( NSString *src, NSString *dest, NSError **error ) {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *newDest = dest;
    for ( int i = 1; [manager fileExistsAtPath:newDest]; i++ ) {
        newDest = [NSString stringWithFormat:@"%@%d.%@", 
                   [dest stringByDeletingPathExtension],
                   i, [dest pathExtension]];
    }

    NSLog( @"%@ move to %@", src, newDest );
    return [manager moveItemAtPath:src toPath:newDest error:error];
}

- (void)moveItem:(id)item {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dirPath = [defaults valueForKey:kPrefDownloadDirectoryKey];
    NSError *error = nil;
    [item setMessage:NSLocalizedString(@"Moving movie file from temporary directory.", nil)];
    if ( moveFile( [item tempFilePath], 
                  [dirPath stringByAppendingPathComponent:[item filename]],
                  &error ) ) {
        [item setMessage:NSLocalizedString(@"Finish.", nil)];
        [item setFinished:YES];
        if ( [defaults valueForKey:kPrefIsRemoveItemKey] ) {
            [itemController removeObject:item];
        }
        if ( [defaults valueForKey:kPrefIsTerminateApplicationKey] ) {
            if ( [[itemController arrangedObjects] count] == 0 ) {
                [NSApp terminate:self];
            }
        }
    } else {
        NSLog( @"%@", error );
        [item setMessage:NSLocalizedString(@"Failed to move file from temporary directory.", nil)];
    }
}

- (void)newSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if ( returnCode == NSCancelButton ) return;
    
    NSString *str = [(id)contextInfo identifier];
    NSUInteger idx = [(id)contextInfo selectedConverter];
    
    if ( [str hasPrefix:kURLNicoVideoMyMyList] ) {
        NSString *urlstr = [kURLNicoVideoMyList stringByAppendingPathComponent:[str lastPathComponent]];
        [multipleWindowController setDefaultConverterIndex:idx];
        [multipleWindowController loadMylist:[NSURL URLWithString:urlstr]];
        [multipleWindowController showWindow:self];
    }
    
    if ( [str hasPrefix:kURLNicoVideoMyList] ) {
        [multipleWindowController setDefaultConverterIndex:idx];
        [multipleWindowController loadMylist:[NSURL URLWithString:str]];
        [multipleWindowController showWindow:self];
        return;
    }
    
    if ( [str hasPrefix:kURLNicoVideoWatch] ) {
        [self addItemWithID:[str lastPathComponent] convertIndex:idx];
        return;
    }
    
    if ( [str hasPrefix:@"http://"] ) {
        [multipleWindowController setDefaultConverterIndex:idx];
        [multipleWindowController loadURL:[NSURL URLWithString:str]];
        [multipleWindowController showWindow:self];
        return;
    }
    
    if ( [str hasPrefix:@"file://"] || [str hasPrefix:@"/"] ) {
        [self addConvertItemWithID:str converterIndex:idx];
        return;
    }
    
    [self addItemWithID:str convertIndex:idx];
}

- (void)newMultipleSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if ( returnCode == NSCancelButton ) return;
    
    for ( id item in [(id)contextInfo items] ) {
        if ( ! [item isOccursError] && ! [item isCancelled] ) {
            [itemController addObject:item];
            id movieLoader = [MovieLoader movieLoaderWithItem:item];
            [movieLoader setCompletionBlock:^{
                if ( ! [item isOccursError] && ! [item isCancelled] ) {
                    if ( [[item command] length] == 0 ) {
                        [self moveItem:item];
                    } else {
                        id converter = [MovieConverter movieConverterWithItem:item];
                        [converter setCompletionBlock:^{
                            if ( ! [item isOccursError] && ! [item isCancelled] ) {
                                [self moveItem:item];
                            }
                        }];
                        [convertVideoQueue addOperation:converter];
                    }
                }
            }];
            [loadVideoQueue addOperation:movieLoader];
        }
    }
}


- (void)addConvertItemWithID:(NSString *)anID converterIndex:(NSUInteger)idx {
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [[defaults valueForKey:kPrefFFMpegConvertSettingsKey] objectAtIndex:idx];
    id item = [[[Item alloc] initWithIdentifier:anID] autorelease];
    [item setConvert:[dict valueForKey:@"name"]];
    [item setCommand:[dict valueForKey:@"command"]];
    [item setExtension:[dict valueForKey:@"extension"]];
    
    [itemController addObject:item];
     */
}

- (void)addItemWithID:(NSString *)anID convertIndex:(NSUInteger)idx {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [[defaults valueForKey:kPrefFFMpegConvertSettingsKey] objectAtIndex:idx];
    id item = [[[Item alloc] initWithIdentifier:anID] autorelease];
    [item setConvert:[dict valueForKey:@"name"]];
    [item setCommand:[dict valueForKey:@"command"]];
    [item setExtension:[dict valueForKey:@"extension"]];
    
    [itemController addObject:item];
    [self beginItem:item];
}

- (void)beginItem:(id)item {
    id infoLoader = [InformationLoader informationLoaderWithItem:item];
    [infoLoader setCompletionBlock:^{
        if ( ! [item isOccursError] && ! [item isCancelled] ) {
            id movieLoader = [MovieLoader movieLoaderWithItem:item];
            [movieLoader setCompletionBlock:^{
                if ( ! [item isOccursError] && ! [item isCancelled] ) {
                    if ( [[item command] length] == 0 ) {
                        [self moveItem:item];
                    } else {
                        id converter = [MovieConverter movieConverterWithItem:item];
                        [converter setCompletionBlock:^{
                            if ( ! [item isOccursError] && ! [item isCancelled] ) {
                                [self moveItem:item];
                            }
                        }];
                        [convertVideoQueue addOperation:converter];
                    }
                }
            }];
            [loadVideoQueue addOperation:movieLoader];
        }
    }];
    [loadInfoQueue addOperation:infoLoader];
}

- (IBAction)remove:(id)sender {
    for ( id item in [itemController selectedObjects] ) {
        [item setCancelled:YES];
        [itemController removeObject:item];
    }
}

- (IBAction)stop:(id)sender {
    for ( id item in [itemController selectedObjects] ) {
        [item setCancelled:YES];
        [item setProgress:0.0];
        [item setLeftTime:0];
        [item setBytePerSeconds:0];
        [item setMessage:@"Cancelled."];
    }
}

- (IBAction)stopAll:(id)sender {
    for ( id item in [itemController arrangedObjects] ) {
        [item setCancelled:YES];
        [item setProgress:0.0];
        [item setLeftTime:0];
        [item setBytePerSeconds:0];
        [item setMessage:@"Cancelled."];
    }
}

- (IBAction)clearAll:(id)sender {
    for ( id item in [itemController arrangedObjects] ) {
        if ( [item isFinished] ) {
            [itemController removeObject:item];
        }
    }
}

- (IBAction)restart:(id)sender {
    for ( id item in [itemController selectedObjects] ) {
        if ( [item isCancelled] || [item isOccursError] ) {
            [item setCancelled:NO];
            [item setOccursError:NO];
            [self beginItem:item];
        }
    }
}

- (IBAction)restartAll:(id)sender {
    for ( id item in [itemController arrangedObjects] ) {
        if ( [item isCancelled] || [item isOccursError] ) {
            [item setCancelled:NO];
            [item setOccursError:NO];
            [self beginItem:item];
        }
    }
}

@end
