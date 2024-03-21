#pragma once
#import <AppKit/AppKit.h>

@interface SWWallpaper : NSObject

@property (readonly) NSScreen* screen;

- (void)setVideo: (NSString*)path;
- (void)start;

- (void)setFps: (int)fps;
- (int)fps;

- (instancetype)initWithScreen: (NSScreen*)screen;
+ (instancetype)newWithScreen: (NSScreen*)screen;


@end
