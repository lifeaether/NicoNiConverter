

#import "MovieConverter.h"
#import "Constants.h"

@implementation MovieConverter


- (id)initWithItem:(Item *)anItem {
    self = [super init];
    if ( self ) {
        item = [anItem retain];
    }
    return self;
}

+ (id)movieConverterWithItem:(Item *)anItem {
    return [[[self alloc] initWithItem:anItem] autorelease];
}

- (void)dealloc {
    // Clean-up code here.
    [item release];
    [super dealloc];
}

- (BOOL)isCancelled {
    return [item isCancelled];
}

static float durationFromOutput( NSString *str ) {
    NSScanner *scanner = [NSScanner scannerWithString:str];
    if ( ! [scanner scanUpToString:@"Duration: " intoString:nil] ) return 0;
    [scanner scanString:@"Duration: " intoString:nil];
    
    int h = 0, m = 0;
    float s = 0;
    [scanner scanInt:&h];
    [scanner scanString:@":" intoString:nil];
    [scanner scanInt:&m];
    [scanner scanString:@":" intoString:nil];
    [scanner scanFloat:&s];
    return s + m*60 + h*60*60;
}

static float aspectFromOutput( NSString *str ) {
    NSScanner *scanner = [NSScanner scannerWithString:str];
    if ( ! [scanner scanUpToString:@"Video: " intoString:nil] ) return 0;
    [scanner scanString:@"Video: " intoString:nil];
    [scanner scanUpToString:@"," intoString:nil];
    [scanner scanString:@"," intoString:nil];
    [scanner scanUpToString:@"," intoString:nil];
    [scanner scanString:@"," intoString:nil];
    
    float w,h;
    [scanner scanFloat:&w];
    [scanner scanString:@"x" intoString:nil];
    [scanner scanFloat:&h];
    if ( h > 0 ) {
        return w / h;
    } else {
        return 0;
    }
}

static NSString *sizeFromAspect( float aspect ) {
    int w = 640;
    int h = 640.0f / aspect;
    return [NSString stringWithFormat:@"%dx%d", w, h];
}

- (void)main {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if ( [self isCancelled] ) return;
    
    [item setProgress:0.0f];
    [item setMessage:NSLocalizedString(@"Converting movie...", nil)];
    
    if ( [[item command] length] == 0 ) {
        [item setMessage:NSLocalizedString(@"Finish.", nil)];
        goto FINISH;
    } else {
        if ( [[item extension] length] == 0 ) {
            [item setMessage:NSLocalizedString(@"Convert file extension is empty. Please set a extension.", nil)];
            goto ERROR;
        }
    }
    
    NSPipe *pipe = [[NSPipe alloc] init];
    NSTask *task = [[NSTask alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ffmpeg = [defaults valueForKey:kPrefFFMpegLaunchPathKey];
    [task setLaunchPath:ffmpeg];
    [task setStandardError:pipe];
    
    NSString *srcPath = [item tempFilePath];
    NSArray *args = [NSArray arrayWithObjects:@"-i", srcPath, nil];
    [task setArguments:args];
    [task launch];
    [task waitUntilExit];
    
    NSData *data = [[pipe fileHandleForReading] availableData];
    NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    float duration = durationFromOutput( str );
    if ( duration == 0 ) {
        [item setMessage:NSLocalizedString(@"Failed to parse duration. Converting movie...", nil)];
        //goto ERROR;
    }
    float aspect = aspectFromOutput( str );
    
    //NSLog( @"duration=%f, aspect=%f", duration, aspect );
    [task release];
    [pipe release];
    
    pipe = [[NSPipe alloc] init];
    task = [[NSTask alloc] init];
    [task setLaunchPath:ffmpeg];
    [task setStandardError:pipe];
    
    NSString *destPath = [srcPath stringByAppendingPathExtension:[item extension]];
    
    NSMutableArray *args2 = [NSMutableArray arrayWithObjects:@"-y", @"-i", srcPath, @"-s", sizeFromAspect( aspect ), destPath, nil];
    [args2 addObjectsFromArray:[[item command] componentsSeparatedByString:@" "]];
    [task setArguments:args2];
    [task launch];
    
    NSDate *beginDate = [NSDate date];
    do {
        NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
        @try {
            data = [[pipe fileHandleForReading] availableData];
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog( @"%@", str );
            NSRange r1 = [str rangeOfString:@"time=" options:NSBackwardsSearch];
            NSUInteger s = NSMaxRange( r1 );
            NSRange r2 = [str rangeOfString:@" " options:NSLiteralSearch range:NSMakeRange(s, [str length] - s)];
            float time = [[str substringWithRange:NSMakeRange( s, r2.location - s )] floatValue];
            float p;
            if ( duration > 0 ) {
                p = time/duration;
            } else {
                p = 0;
            }
            [item setProgress:p];
            [item setLeftTime:-[beginDate timeIntervalSinceNow]*(1.0/p-1)];
            if ( [self isCancelled] ) {
                [task terminate];
            }
        } @catch ( NSException *ex ) {
            NSLog( @"%@", ex );
        }
        [pool2 drain];
    } while ( [task isRunning] );
    
    if ( [task terminationStatus] ) {
        [item setMessage:NSLocalizedString(@"Failed to convert.", nil)];
        goto ERROR;
    }
    
    [item setTempFilePath:destPath];
    [item setProgress:1.0f];
    [item setMessage:NSLocalizedString(@"Finish.", nil)];
    goto FINISH;
ERROR:
    [item setOccursError:YES];
FINISH:
    [task release];
    [pipe release];
    [pool drain];
}

@end
