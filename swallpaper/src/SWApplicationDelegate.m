#import <SWApplicationDelegate.h>
#import <SWWallpaper.h>
#import "swallpaper-Swift.h"

@implementation SWApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    SWWallpaper* wallpaper = [SWWallpaper newWithScreen: [NSScreen mainScreen]];
    [wallpaper setVideo: @"video.mp4"];
    [wallpaper start];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)sender hasVisibleWindows:(BOOL)flag {
    if (self.uiWindow) {
        [self.uiWindow deminiaturize: self];
    }
    
    return true;
}

@end
