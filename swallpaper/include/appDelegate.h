#pragma once
#import <rendering/renderer.h>
#import <AppKit/AppKit.h>

@interface ApplicationDelegate : NSObject<NSApplicationDelegate>

@property Renderer* renderer;
@property NSThread* renderThread;

- (void)mainLoop;

@end
