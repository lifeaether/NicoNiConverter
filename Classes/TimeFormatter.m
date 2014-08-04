

#import "TimeFormatter.h"


@implementation TimeFormatter

- (NSString *)stringForObjectValue:(id)anObject {
    float t = [anObject floatValue];
    if ( t == 0 ) return @"";
    if ( t < 60 ) return [NSString stringWithFormat:NSLocalizedString(@"%.0f seconds remaining", nil), t];
    if ( t < 60*60 ) return [NSString stringWithFormat:NSLocalizedString(@"%.0f minutes remaining", nil), (t+30)/60 ];
    return [NSString stringWithFormat:NSLocalizedString(@"%.0f hours remaining", nil), (t+60*30)/3600 ];
}

@end
