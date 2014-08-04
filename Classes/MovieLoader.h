

#import <Foundation/Foundation.h>
#import "Item.h"

@interface MovieLoader : NSOperation {
@private
    BOOL isExecuting;
    BOOL isFinished;
    Item *item;
}

- (id)initWithItem:(Item *)anItem;
+ (id)movieLoaderWithItem:(Item *)anItem;

@property (nonatomic, readonly) BOOL isExecuting;
@property (nonatomic, readonly) BOOL isFinished;

- (void)complete;

@end
