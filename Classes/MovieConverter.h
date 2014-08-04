

#import <Foundation/Foundation.h>
#import "Item.h"

@interface MovieConverter : NSOperation {
@private
    Item *item;
}

- (id)initWithItem:(Item *)anItem;
+ (id)movieConverterWithItem:(Item *)anItem;

@end
