#pragma once
#import <AppKit/AppKit.h>
#import <elements/SWTypes.h>
#import <QuartzCore/QuartzCore.h>

@interface SWEnumParser : NSObject

+ (SWSizeConstraint)parseSWSizeConstraint:(NSString*)str;

@end
