#import <SWApplicationDelegate.h>
#import <SWWallpaper.h>
#import <SWGradientLayer.h>
#import "swallpaper-Swift.h"

@implementation SWApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    SWWallpaper* wallpaper = [SWWallpaper newWithScreen: [NSScreen mainScreen]];
    [wallpaper setScene: @"/users/user/desktop/scene.swal"];
    [wallpaper start];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)sender hasVisibleWindows:(BOOL)flag {
    if (self.uiWindow) {
        [self.uiWindow deminiaturize: self];
    }
    
    return true;
}

@end

//    NSArray* colors = @[(id)[[NSColor colorWithCalibratedRed:0.259 green:0.267 blue:0.29 alpha:0.5] CGColor],
//                            (id)[[NSColor colorWithCalibratedRed:0.259 green:0.267 blue:0.29 alpha:0.5] CGColor],
//                            (id)[[[NSColor whiteColor] colorWithAlphaComponent: 0.5] CGColor],
//                            (id)[[NSColor colorWithCalibratedRed:0.259 green:0.267 blue:0.29 alpha:0.5] CGColor],
//                            (id)[[NSColor colorWithCalibratedRed:0.259 green:0.267 blue:0.29 alpha:0.5] CGColor]];
//    NSArray* colors = @[(id)[[[NSColor redColor] colorWithAlphaComponent:0.5] CGColor],
//                            (id)[[[NSColor orangeColor] colorWithAlphaComponent: 0.5] CGColor],
//                            (id)[[[NSColor yellowColor] colorWithAlphaComponent: 0.5] CGColor],
//                            (id)[[[NSColor greenColor] colorWithAlphaComponent: 0.5] CGColor],
//                            (id)[[[NSColor blueColor] colorWithAlphaComponent: 0.5] CGColor],
//                            (id)[[[NSColor purpleColor] colorWithAlphaComponent: 0.5] CGColor],
//                            (id)[[NSColor colorWithCalibratedRed:75/255.0 green:130/255.0 blue:130/255.0 alpha:0.5] CGColor],
//                            (id)[[[NSColor blueColor] colorWithAlphaComponent: 0.5] CGColor]];
