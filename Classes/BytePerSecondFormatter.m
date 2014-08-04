

#import "BytePerSecondFormatter.h"


@implementation BytePerSecondFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
	float bps = [anObject floatValue];
    
    if ( bps == 0 ) return @"";
    if ( bps < 1024 ) return [NSString stringWithFormat:NSLocalizedString(@"%.0f (bytes/s)", nil), bps];
    if ( bps < 1024*1024 ) return [NSString stringWithFormat:NSLocalizedString(@"%.0f (KB/s)", nil), bps/1024];
    return [NSString stringWithFormat:NSLocalizedString(@"%.2f (MB/s)", nil), bps/1024/1024];

}

@end
