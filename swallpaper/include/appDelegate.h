#pragma once
#import <rendering/renderer.h>
#import <AppKit/AppKit.h>

@interface ApplicationDelegate : NSObject<NSApplicationDelegate>

@property NSWindow* uiWindow;
@property Renderer* renderer;
@property NSThread* renderThread;

- (void)mainLoop;

@end
