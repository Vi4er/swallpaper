#pragma once
#import <AppKit/AppKit.h>
#import <elements/SWTypes.h>
#import <QuartzCore/QuartzCore.h>
#import <elements/SWEvent.h>

@interface SWEnumParser : NSObject

+ (SWSizeConstraint)parseSWSizeConstraint:(NSString*)str;
+ (SWEventType)parseSWEvent:(NSString*)str;

@end
