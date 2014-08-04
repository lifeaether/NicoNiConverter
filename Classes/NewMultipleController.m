
#import "NewMultipleController.h"
#import "NSURLConnection+BlocksAddition.h"
#import "Item.h"
#import "Constants.h"
#import "InformationLoader.h"

static NSString * const kOperationCountKey = @"operationCount";
static NSString * const kLoadingKey = @"isLoading";
static NSString * const kMessageKey = @"message";

@implementation NewMultipleController
@synthesize itemController;

@synthesize message, isLoading, defaultConverterIndex;

- (id)init {
    return [self initWithWindowNibName:@"NewMultiple"];
}

- (id)initWithWindow:(NSWindow *)window {
    if ((self = [super initWithWindow:window])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    [loadQueue removeObserver:self forKeyPath:kOperationCountKey];
    [loadQueue cancelAllOperations];
    [loadQueue release];
    [itemController release];
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSArray *)items {
    return [itemController content];
}

- (void)awakeFromNib {
    if ( ! loadQueue ) {
        loadQueue = [[NSOperationQueue alloc] init];
        [loadQueue setMaxConcurrentOperationCount:3];
        [loadQueue addObserver:self forKeyPath:kOperationCountKey options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( [loadQueue operationCount] == 0 ) {
        [self willChangeValueForKey:kLoadingKey];
        [self setLoading:NO];
        [self didChangeValueForKey:kLoadingKey];
        [self willChangeValueForKey:kMessageKey];
        [self setMessage:NSLocalizedString( @"Loaded movie informations.", nil )];
        [self didChangeValueForKey:kLoadingKey];
    }
}

- (void)addOperationWithID:(NSString *)identifier {
    Item *item = [[[Item alloc] initWithIdentifier:identifier] autorelease];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [[defaults valueForKey:kPrefFFMpegConvertSettingsKey] objectAtIndex:defaultConverterIndex];
    [item setConvert:[dict valueForKey:@"name"]];
    [item setCommand:[dict valueForKey:@"command"]];
    [item setExtension:[dict valueForKey:@"extension"]];
    [itemController addObject:item];
    InformationLoader *loader = [InformationLoader informationLoaderWithItem:item];
    [loadQueue addOperation:loader];
}

- (void)loadURL:(NSURL *)url {
    [self willChangeValueForKey:kLoadingKey];
    [self setLoading:YES];
    [self didChangeValueForKey:kLoadingKey];
    [self willChangeValueForKey:kMessageKey];
    [self setMessage:NSLocalizedString( @"Loading web page...", nil )];
    [self didChangeValueForKey:kLoadingKey];
    [loadQueue cancelAllOperations];
    [itemController removeObjects:[itemController arrangedObjects]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendRequest:request completeBlock:^( NSData *data ) {
        [self setMessage:NSLocalizedString( @"Loading movie information...", nil )];
        NSError *error = nil;
        NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:&error] autorelease];
        NSArray *nodes = [doc nodesForXPath:@"//@href" error:&error];
        if ( [nodes count] > 0 ) {
            nodes = [[NSSet setWithArray:nodes] allObjects];
            for ( id node in nodes ) {
                NSString *path = [node stringValue];
                if ( [[[path stringByDeletingLastPathComponent] lastPathComponent] isEqualToString:@"watch"] ) {
                    [self addOperationWithID:[path lastPathComponent]];
                }
            } 
        } else {
            [self willChangeValueForKey:kMessageKey];
            [self setMessage:NSLocalizedString( @"No movie found.", nil )];
            [self didChangeValueForKey:kLoadingKey];
            [self willChangeValueForKey:kLoadingKey];
            [self setLoading:NO];
            [self didChangeValueForKey:kLoadingKey];
        }
    } errorBlock:^( NSError *error ) {
        [self willChangeValueForKey:kMessageKey];
        [self setMessage:NSLocalizedString( @"Failed to load web page.", nil )];
        [self didChangeValueForKey:kLoadingKey];
        NSLog( @"%@", error );
    }];
}

- (void)loadMylist:(NSURL *)url {
    [self willChangeValueForKey:kLoadingKey];
    [self setLoading:YES];
    [self didChangeValueForKey:kLoadingKey];
    [self willChangeValueForKey:kMessageKey];
    [self setMessage:NSLocalizedString( @"Loading mylist...", nil )];
    [self didChangeValueForKey:kLoadingKey];
    [loadQueue cancelAllOperations];
    [itemController removeObjects:[itemController arrangedObjects]];
    NSString *urlString = [[url absoluteString] stringByAppendingString:@"?rss=2.0"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendRequest:request completeBlock:^( NSData *data ) {
        [self setMessage:NSLocalizedString( @"Loading movie information...", nil )];
        NSError *error = nil;
        NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentValidate error:&error] autorelease];
        NSArray *nodes = [doc nodesForXPath:@"/rss/channel/item/link" error:&error];
        if ( [nodes count] > 0 ) {
            for ( id node in nodes ) {
                [self addOperationWithID:[[node stringValue] lastPathComponent]];
            }
        } else {
            [self willChangeValueForKey:kMessageKey];
            [self setMessage:NSLocalizedString( @"No movie found.", nil )];
            [self didChangeValueForKey:kLoadingKey];
            [self willChangeValueForKey:kLoadingKey];
            [self setLoading:NO];
            [self didChangeValueForKey:kLoadingKey];
        }
    } errorBlock:^( NSError *error ) {
        [self willChangeValueForKey:kMessageKey];
        [self setMessage:NSLocalizedString( @"Failed to load mylist.", nil )];
        [self didChangeValueForKey:kLoadingKey];
        NSLog( @"%@", error );
        [self setLoading:NO];
    }];
}

- (IBAction)cancel:(id)sender {
    [[self window] close];
    [NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (IBAction)OK:(id)sender {
    [[self window] close];
    [NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (IBAction)showWindow:(id)sender {
    id delegate = [NSApp delegate];
    NSWindow *modal = [delegate window];
    [NSApp beginSheet:[self window]
       modalForWindow:modal
        modalDelegate:delegate
       didEndSelector:@selector(newMultipleSheetDidEnd:returnCode:contextInfo:)
          contextInfo:self];
}

@end
