
#import <Foundation/Foundation.h>


@interface Item : NSObject {
@private
    NSString *identifier;
    NSString *convert;
    NSString *command;
    NSString *extension;
    NSString *tempFilePath;
    
    id information;
    NSImage *image;
    
    NSString *message;
    float bytePerSeconds;
    int leftTime;
    
    float progress;
    
    BOOL isFinished;
    BOOL isOccursError;
    BOOL isCancelled;
}

- (id)initWithIdentifier:(NSString *)anID;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *convert;
@property (nonatomic, copy) NSString *command;
@property (nonatomic, copy) NSString *extension;

@property (nonatomic, copy) NSString *tempFilePath;
@property (readonly) NSString *filename;

@property (nonatomic, retain) id information;
@property (nonatomic, retain) NSImage *image;

@property (nonatomic, copy) NSString *message;
@property (nonatomic) float bytePerSeconds;
@property (nonatomic) int leftTime;

@property (nonatomic) float progress;

@property (nonatomic, setter = setFinished: ) BOOL isFinished;
@property (nonatomic, setter = setOccursError: ) BOOL isOccursError;
@property (nonatomic, setter = setCancelled: ) BOOL isCancelled;

@end
