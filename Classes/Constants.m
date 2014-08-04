
#import "Constants.h"

NSString * const kImageDropHere = @"drophere.png";
NSString * const kHelpURL = @"";
NSString * const kApplicationErrorDomain = @"jp.lifeaether.NicoNiConverter";

NSString * const kPrefDownloadDirectoryKey = @"DownloadDirectory";
NSString * const kPrefDownloadDirectoriesKey = @"DownloadDirectories";
NSString * const kPrefIsRemoveItemKey = @"IsRemoveItem";
NSString * const kPrefIsTerminateApplicationKey = @"IsTerminateApplication";
NSString * const kPrefFFMpegLaunchPathKey = @"FFMpegLaunchPath";
NSString * const kPrefFFMpegConvertSettingsKey = @"FFMpegConvertSettings";

NSString * const kURLNicoVideoAPIGetThumbInfo = @"http://ext.nicovideo.jp/api/getthumbinfo/";
NSString * const kURLNicoVideoAPIGetFLVInfo = @"http://flapi.nicovideo.jp/api/getflv/";
NSString * const kURLNicoVideoWatch = @"http://www.nicovideo.jp/watch/";
NSString * const kURLNicoVideoMyList = @"http://www.nicovideo.jp/mylist/";
NSString * const kURLNicoVideoMyMyList = @"http://www.nicovideo.jp/my/mylist/#/";
NSString * AppTemporaryDirectory() {
	return [NSTemporaryDirectory() stringByAppendingPathComponent:@"jp.lifeaether.NicoNiConverter"];
}

NSError * AppErrorDomain( NSInteger code, NSString *description, NSString *reason ) {
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:description,
						  NSLocalizedDescriptionKey,
						  reason, NSLocalizedFailureReasonErrorKey, nil];
	return [NSError errorWithDomain:kApplicationErrorDomain code:code userInfo:info];
}