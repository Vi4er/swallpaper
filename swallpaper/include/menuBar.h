#pragma once
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class MenuBarHandler;

@interface NonConstrainedNSWindow : NSWindow
@end

@interface MenuBarWindow : NonConstrainedNSWindow

- (CGFloat)getMenuBarHeight;
- (void)updatePositionAndSize: (CGRect*)leftRect rightRect:(CGRect*)rightRect;

- (instancetype)initWithMenuBarHandler: (MenuBarHandler*)handler screen: (NSScreen*)screen;
+ (instancetype)newWithMenuBarHandler: (MenuBarHandler*)handler screen: (NSScreen*)screen;

@end

@interface MenuBarHandler : NSObject

@property NSMutableArray<MenuBarWindow*>* windows;

// TOOD: Return only 2 floats, wasting space using 4
- (CGRect)getLeftMenuBarRect;
- (CGRect)getRightMenuBarRect;
 
- (void)appDidActivate:(NSNotification* )notification;

@end
