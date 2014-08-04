
#import "MovieLoader.h"
#import "Constants.h"
#import "NSURLConnection+BlocksAddition.h"
#import "NSXMLNode+XPathAddition.h"

static NSString * const kFinishedKey = @"isFinished";
static NSString * const kExecutingKey = @"isExecuting";


@implementation MovieLoader

@synthesize isExecuting, isFinished;

- (id)initWithItem:(Item *)anItem {
    if ((self = [super init])) {
        item = [anItem retain];
        isExecuting = NO;
        isFinished = NO;
    }
    
    return self;
}

+ (id)movieLoaderWithItem:(Item *)anItem {
    return [[[self alloc] initWithItem:anItem] autorelease];
}

- (id)init {
    return [self initWithItem:nil];
}

- (void)dealloc {
    // Clean-up code here.
    [item release];
    [super dealloc];
}

static NSDictionary *videoAttributesFromData( NSData *data ) {
    NSString *info = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	NSScanner *scanner = [NSScanner scannerWithString:info];
	NSCharacterSet *chars = [NSCharacterSet characterSetWithCharactersInString:@"&="];
	
	while ( ![scanner isAtEnd] ) {
		NSString *scannedKey, *scannedValue;
		[scanner scanUpToCharactersFromSet:chars intoString:&scannedKey];
		[scanner scanCharactersFromSet:chars intoString:nil];
		[scanner scanUpToCharactersFromSet:chars intoString:&scannedValue];
		[scanner scanCharactersFromSet:chars intoString:nil];
		if ( scannedKey && scannedValue ) {
            NSString *unescape = [scannedValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [attributes setValue:unescape forKey:scannedKey];
        }
	}
	//NSLog( @"%@", [attributes description]);
    return attributes;
}

- (void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [AppTemporaryDirectory() stringByAppendingPathComponent:[item identifier]];
    if ( [manager fileExistsAtPath:path] ) {
        [self complete];
        [item setTempFilePath:path];
        goto FINISH;
    }
    
    NSURL *url = [NSURL URLWithString:[kURLNicoVideoAPIGetFLVInfo stringByAppendingString:[item identifier]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [item setMessage:NSLocalizedString( @"Loading video...", nil )];
    
    void (^errorBlock)( NSError * ) = ^( NSError *error ) {
        NSLog( @"%@", error );
        [item setOccursError:YES];
        [item setMessage:NSLocalizedString( @"Failed to load video.", nil )];
        [self willChangeValueForKey:kExecutingKey];
        [self willChangeValueForKey:kFinishedKey];
        isExecuting = NO;
        isFinished = YES;
        [self didChangeValueForKey:kExecutingKey];
        [self didChangeValueForKey:kFinishedKey];
    };
    
    [NSURLConnection sendRequest:request completeBlock:^( NSData *receivedData ) {
        NSDictionary *attr = videoAttributesFromData( receivedData );
        if ( [attr valueForKey:@"url"] != nil ) {
            NSURL *url = [NSURL URLWithString:[kURLNicoVideoWatch stringByAppendingPathComponent:[item identifier]]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [NSURLConnection sendRequest:request completeBlock:^( NSData *receivedData ){
                NSURL *url = [NSURL URLWithString:[attr valueForKey:@"url"]];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [NSURLConnection sendRequest:request completeBlock:^( NSData *receivedData ) {
                    if ( [receivedData writeToFile:path atomically:NO] ) {
                        [item setTempFilePath:path];
                        [item setMessage:NSLocalizedString( @"Loaded video.", nil )];
                        [self complete];
                    } else {
                        [item setOccursError:YES];
                        [item setMessage:NSLocalizedString( @"Failed to write data.", nil )];
                    }
                } errorBlock:errorBlock progressingBlock:^( float percent, float time, float bytePerSecond ) {
                    [item setProgress:percent]; 
                    [item setLeftTime:time];
                    [item setBytePerSeconds:bytePerSecond];
                    if ( [self isCancelled] ) {
                        [self complete];
                        return NO;
                    } else {
                        return YES;
                    }
                }];
            } errorBlock:errorBlock];
        } else {
            if ( [[attr valueForKey:@"closed"] isEqualToString:@"1"] ) {
                errorBlock( AppErrorDomain(0, @"Failed to get flv information from nicovideo API.", @"You are logout." ) );
            } else {
                errorBlock( AppErrorDomain(0, @"Failed to get flv information from nicovideo API.", @"Passing invalid URL or deleted URL." ) );
            }
        }
    } errorBlock:errorBlock];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    } while ( ! [self isFinished] );
    
FINISH:
    [pool drain];
}

- (void)complete {
    [item setBytePerSeconds:0];
    [item setLeftTime:0];
    [self willChangeValueForKey:kExecutingKey];
    [self willChangeValueForKey:kFinishedKey];
    isExecuting = NO;
    isFinished = YES;
    [self didChangeValueForKey:kExecutingKey];
    [self didChangeValueForKey:kFinishedKey];
}

- (void)start {
    if ( [self isCancelled] ) {
        [self willChangeValueForKey:kFinishedKey];
        isFinished = YES;
        [self didChangeValueForKey:kFinishedKey];
    } else {
        [self willChangeValueForKey:kExecutingKey];
        isExecuting = YES;
        [self didChangeValueForKey:kExecutingKey];
        [self main];
    }
}

- (BOOL)isCancelled {
    return [item isCancelled];
}

- (BOOL)isConcurrent {
    return YES;
}

@end
