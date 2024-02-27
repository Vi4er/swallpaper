#pragma once
#import <rendering/renderer.h>
#import <AppKit/AppKit.h>

@interface ApplicationDelegate : NSObject<NSApplicationDelegate>

@property Renderer* renderer;

- (void)mainLoop;

@end
