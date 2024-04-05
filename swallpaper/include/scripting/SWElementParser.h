#pragma once
#import <AppKit/AppKit.h>
#import <elements/SWElement.h>

@interface SWElementParser : NSObject

+ (SWElement*)parseFile:(NSString*)path;

+ (NSString*)parseString:(NSString*)str;
+ (NSColor*)parseColor:(NSString*)str;
+ (SWPoint*)parseSWPoint:(NSString*)str;
+ (SWSize*)parseSWSize:(NSString*)str;
+ (SWVector2*)parseSWVector2:(NSString*)str;
+ (NSNumber*)parseNumber:(NSString*)str;
+ (NSNumber*)parseBoolean:(NSString*)str;
+ (NSImage*)parseImage:(NSString*)str;

@end
