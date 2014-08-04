

#import "NSURLConnection+BlocksAddition.h"


@interface NSURLConnectionBlocksAddtionDelegate : NSObject {
@private
    NSMutableData *receivedData;
    long long expectedLength;
    BOOL (^progressingBlock)( float percent, float time, float bytePerSecond );
    void (^completeBlock)( NSData *receivedData );
    void (^errorBlock)( NSError *error );
    
    NSDate *beginDate;
}

- (id)initWithCompleteBlock:( void (^)( NSData *receivedData ) )compelete errorBlock:( void (^)( NSError *error ) )error progressingBlock:( BOOL (^)( float percent, float time, float bytePerSecond ) )progressing;

@end

@implementation NSURLConnectionBlocksAddtionDelegate

- (id)initWithCompleteBlock:( void (^)( NSData *receivedData ) )compelete errorBlock:( void (^)( NSError *error ) )error progressingBlock:( BOOL (^)( float percent, float time, float bytePerSecond ) )progressing
{
    self = [super init];
    if ( self ) {
        receivedData = [[NSMutableData alloc] init];
        completeBlock = [compelete copy];
        progressingBlock = [progressing copy];
        errorBlock = [error copy];
    }
    return self;
}

- (void)dealloc {
    [errorBlock release];
    [completeBlock release];
    [progressingBlock release];
    [receivedData release];
    [beginDate release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedLength = [response expectedContentLength];
    [receivedData setLength:0];
    beginDate = [[NSDate alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    if ( progressingBlock ) {
        float l = [receivedData length];
        NSTimeInterval t = -[beginDate timeIntervalSinceNow];
        float p = expectedLength > 0 ? l/expectedLength : 0;
        float r = ((1.0f - p) * t) / p;
        float b = l / t;
        if ( ! progressingBlock( p, r, b ) ) {
            [connection cancel];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ( completeBlock ) {
        completeBlock( receivedData );
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ( errorBlock ) {
        errorBlock( error );
    }
}

@end

@implementation NSURLConnection (BlocksAddition)

+ (void)sendRequest:(NSURLRequest *)request completeBlock:( void (^)( NSData *receivedData ) )complete errorBlock:( void (^)( NSError *errror ) )error
{
    id delegate = [[[NSURLConnectionBlocksAddtionDelegate alloc] initWithCompleteBlock:complete errorBlock:error progressingBlock:nil] autorelease];
    [self connectionWithRequest:request delegate:delegate];
}

+ (void)sendRequest:(NSURLRequest *)request completeBlock:( void (^)( NSData *receivedData ) )complete errorBlock:( void (^)( NSError *errror ) )error progressingBlock:( BOOL (^)( float percent, float time, float bytePerSecond ) )progressing {
    id delegate = [[[NSURLConnectionBlocksAddtionDelegate alloc] initWithCompleteBlock:complete errorBlock:error progressingBlock:progressing] autorelease];
    [self connectionWithRequest:request delegate:delegate];
}

@end