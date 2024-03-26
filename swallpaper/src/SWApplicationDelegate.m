#import <SWApplicationDelegate.h>
#import <SWWallpaper.h>
#import <SWGradientLayer.h>
#import "swallpaper-Swift.h"

@implementation SWApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    SWWallpaper* wallpaper = [SWWallpaper newWithScreen: [NSScreen mainScreen]];
    [wallpaper setScene: @"/users/user/desktop/scene.swal"];
    [wallpaper start];
    
    // Gradient test

    NSArray* colors = @[(id)[[[NSColor grayColor] colorWithAlphaComponent:0.5] CGColor],
                            (id)[[[NSColor grayColor] colorWithAlphaComponent: 0.5] CGColor],
                            (id)[[[NSColor whiteColor] colorWithAlphaComponent: 0.5] CGColor],
                            (id)[[[NSColor grayColor] colorWithAlphaComponent: 0.5] CGColor],
                            (id)[[[NSColor grayColor] colorWithAlphaComponent: 0.5] CGColor]];
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(1, 0);
    [wallpaper.menuBar setGradient: colors startPoint:startPoint endPoint:endPoint];
    [(SWGradientLayer*)wallpaper.menuBar.contentView.layer setEffect: kSWGradientEffectWave];
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
