#pragma once
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class MenuBarHandler;

@interface MenuBarWindow : NSWindow

@property const MenuBarHandler* menuBarHandler;

- (instancetype)initWithMenuBarHandler: (MenuBarHandler*)handler;
+ (instancetype)newWithMenuBarHandler: (MenuBarHandler*)handler;

@end

@interface MenuBarHandler : NSObject

@property NSMutableArray<MenuBarWindow*>* windows;

- (CGRect)getLeftMenuBarRect;
 
- (void)appDidActivate:(NSNotification* )notification;

@end
