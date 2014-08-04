
#import <Foundation/Foundation.h>

extern NSString * const kImageDropHere;
extern NSString * const kHelpURL;

extern NSString * const kApplicationErrorDomain;


extern NSString * const kPrefDownloadDirectoryKey;
extern NSString * const kPrefDownloadDirectoriesKey;
extern NSString * const kPrefIsRemoveItemKey;
extern NSString * const kPrefIsTerminateApplicationKey;
extern NSString * const kPrefFFMpegLaunchPathKey;
extern NSString * const kPrefFFMpegConvertSettingsKey;

extern NSString * const kURLNicoVideoAPIGetThumbInfo;
extern NSString * const kURLNicoVideoAPIGetFLVInfo;
extern NSString * const kURLNicoVideoWatch;
extern NSString * const kURLNicoVideoMyList;
extern NSString * const kURLNicoVideoMyMyList;

NSString * AppTemporaryDirectory();
NSError * AppErrorDomain( NSInteger code, NSString *description, NSString *reason );