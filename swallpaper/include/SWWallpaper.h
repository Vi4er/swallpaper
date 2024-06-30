#pragma once
#import <AppKit/AppKit.h>
#import <SWNonConstrainedWindow.h>
#import <SWMenuBar.h>
#import <elements/SWElement.h>
#import <rendering/SWRenderer.h>
#import <QuartzCore/QuartzCore.h>

@interface SWWallpaper<CAMetalDisplayLinkDelegate> : SWElement

@property (readonly) SWNonConstrainedWindow* window;
@property (readonly) SWMenuBar* menuBar;
@property (readonly) SWRenderer* renderer;

- (void)setScene:(NSString*)path;
- (void)start;

- (void)setFps:(int)fps;
- (int)fps;

- (instancetype)initWithScreen:(NSScreen*)screen;
+ (instancetype)newWithScreen:(NSScreen*)screen;

+ (NSMutableArray<SWWallpaper*>*)wallpapers;

@end
