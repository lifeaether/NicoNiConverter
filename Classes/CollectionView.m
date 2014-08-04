
#import "CollectionView.h"
#import "Constants.h"
#import "NicoNiConverterAppDelegate.h"

@implementation CollectionView

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    [dropHere release];
    [super dealloc];
}

- (void)awakeFromNib
{
    if ( ! dropHere ) {
        NSString *path = [[NSBundle mainBundle] pathForImageResource:kImageDropHere];
        dropHere = [[NSImage alloc] initWithContentsOfFile:path];
        NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, NSURLPboardType, nil];
        [self registerForDraggedTypes:types];
        
        [[self window] setBackgroundColor:[NSColor whiteColor]];
    }
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	return NSDragOperationCopy;
}

- (void)draggingEnded:(id < NSDraggingInfo >)sender
{
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
	NSPasteboard *board = [sender draggingPasteboard];
	[[NSApp delegate] openWithString:[board stringForType:NSStringPboardType]];
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    if ( [[self content] count] == 0 ) {
        NSRect f = [self frame];
        NSSize s = [dropHere size];
        NSRect r;
        r.origin.x = (f.size.width - s.width)/2;
        r.origin.y = (f.size.height - s.height)/2;
        r.size = s;
        [dropHere drawInRect:r fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0 respectFlipped:YES hints:nil];
    
        NSFont *font = [NSFont userFontOfSize:14.0];
        NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor grayColor], NSForegroundColorAttributeName,
                          font, NSFontAttributeName, nil];
        NSString *str = NSLocalizedString(@"Drag movie URL or link here.", @"");
        NSPoint p;
        s = [str sizeWithAttributes:attr];
        p.x = (f.size.width - s.width)/2;
        p.y = NSMaxY( r ) + s.height * 0.5;
        [str drawAtPoint:p withAttributes:attr];
    }
}

@end
