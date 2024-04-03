#pragma once
#import <AppKit/AppKit.h>
#import <SWNonConstrainedWindow.h>
#import <SWMenuBar.h>
#import <elements/SWElement.h>

@interface SWWallpaper : SWElement

@property (readonly) NSScreen* screen;
@property (readonly) SWNonConstrainedWindow* window;
@property (readonly) SWMenuBar* menuBar;

- (void)setScene: (NSString*)path;
- (void)start;

- (void)setFps: (int)fps;
- (int)fps;

- (instancetype)initWithScreen: (NSScreen*)screen;
+ (instancetype)newWithScreen: (NSScreen*)screen;


@end
