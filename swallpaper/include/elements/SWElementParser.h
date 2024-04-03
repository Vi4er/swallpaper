#pragma once
#import <AppKit/AppKit.h>
#import <elements/SWElement.h>

@interface SWElementParser : NSObject

+ (SWElement*)parseFile: (NSString*)path;
+ (NSColor*)parseColor: (NSString*)str;
+ (SWPosition)parseSWPosition: (NSString*)str;
+ (SWSize)parseSWSize: (NSString*)str;
+ (CGPoint)parseCGPoint: (NSString*)str;
+ (NSNumber*)parseNumber: (NSString*)str;
+ (int)parseBoolean: (NSString*)str;
+ (SWSizeConstraint)parseSWSizeConstraint: (NSString*)str;

@end
