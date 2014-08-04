

#import <Foundation/Foundation.h>


@interface NSURLConnection (NSURLConnectionBlocksAddition)

+ (void)sendRequest:(NSURLRequest *)request completeBlock:( void (^)( NSData *receivedData ) )complete errorBlock:( void (^)( NSError *errror ) )error;
+ (void)sendRequest:(NSURLRequest *)request completeBlock:( void (^)( NSData *receivedData ) )complete errorBlock:( void (^)( NSError *errror ) )error progressingBlock:( BOOL (^)( float percent, float resttime, float bytePerSecond ) )progressing;

@end