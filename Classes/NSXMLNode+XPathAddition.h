

#import <Foundation/Foundation.h>


@interface NSXMLNode (NSXMLNodeXPathAddition)

- (NSString *)stringValueForXPath:(NSString *)xpath error:(NSError **)error;

@end