#pragma once
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class MenuBarHandler;

@interface MenuBarWindow : NSWindow

- (CGFloat)getMenuBarHeight;
- (void)updatePositionAndSize: (CGRect*)rect;

- (instancetype)initWithMenuBarHandler: (MenuBarHandler*)handler;
+ (instancetype)newWithMenuBarHandler: (MenuBarHandler*)handler;

@end

@interface MenuBarHandler : NSObject

@property NSMutableArray<MenuBarWindow*>* windows;

- (CGRect)getLeftMenuBarRect;
 
- (void)appDidActivate:(NSNotification* )notification;

@end
