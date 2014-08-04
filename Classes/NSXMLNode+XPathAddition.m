
#import "NSXMLNode+XPathAddition.h"

@implementation NSXMLNode (NSXMLNodeXPathAddition)

- (NSString *)stringValueForXPath:(NSString *)xpath error:(NSError **)error {
    NSArray *nodes;
    nodes = [self nodesForXPath:xpath error:error];
    if ( [nodes count] > 0 ) {
        return [[nodes objectAtIndex:0] stringValue];
    } else {
        return nil;
    }
}

@end