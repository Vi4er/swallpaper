#pragma once
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class MenuBarHandler;

@interface NonConstrainedNSWindow : NSWindow
@end

@interface MenuBarWindow : NonConstrainedNSWindow

- (CGFloat)getMenuBarHeight;
- (void)updatePositionAndSize: (NSRect*)leftRect rightRect:(NSRect*)rightRect;
- (void)setGradient: (NSArray*)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

- (instancetype)initWithMenuBarHandler: (MenuBarHandler*)handler screen: (NSScreen*)screen;
+ (instancetype)newWithMenuBarHandler: (MenuBarHandler*)handler screen: (NSScreen*)screen;

@end

@interface MenuBarHandler : NSObject

@property NSMutableArray<MenuBarWindow*>* windows;

// TOOD: Return only 2 floats, wasting space using 4
- (NSRect)getLeftMenuBarRect;
- (NSRect)getRightMenuBarRect;
 
- (void)appDidActivate:(NSNotification* )notification;

@end
