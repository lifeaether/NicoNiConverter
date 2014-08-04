
#import <Foundation/Foundation.h>
#import "Item.h"

@interface InformationLoader : NSOperation {
    Item *item;
}

+ (id)informationLoaderWithItem:(Item *)anItem;
- (id)initWithItem:(Item *)anItem;

@end
