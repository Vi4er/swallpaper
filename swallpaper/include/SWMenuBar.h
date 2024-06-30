#pragma once
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <SWNonConstrainedWindow.h>

@interface SWMenuBar : SWNonConstrainedWindow

- (CGFloat)getMenuBarHeight;
- (void)updatePositionAndSize;
- (void)updatePositionAndSize:(NSRect*)leftRect rightRect:(NSRect*)rightRect;
- (void)setGradient:(NSArray*)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

+ (NSRect)getLeftMenuBarRect;
+ (NSRect)getRightMenuBarRect;

- (instancetype)initWithScreen:(NSScreen*)screen;
+ (instancetype)newWithScreen:(NSScreen*)screen;

@end
