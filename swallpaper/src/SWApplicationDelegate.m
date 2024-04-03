#import <SWApplicationDelegate.h>
#import <SWWallpaper.h>
#import <SWGradientLayer.h>
#import <elements/SWImageElement.h>
#import <elements/SWTextElement.h>
#import "swallpaper-Swift.h"

@implementation SWApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    SWWallpaper* wallpaper = [SWWallpaper newWithScreen: [NSScreen mainScreen]];
    [wallpaper setScene: @"scene.swal"];
    [wallpaper setFps:60];
    [wallpaper start];

    {
        // TODO: Make proper elements API, especially for adding element children (should be able to nest SWTextElement and shit)
        
        // Frame

        SWElement* frame = [SWElement newWithParent:wallpaper];
        [frame setProperty:@"backgroundColor" value:@"rgb(0, 0, 0, 127.5)"];
        [frame setProperty:@"anchorPoint" value:@"{0.5, 0.5}"];
        [frame setProperty:@"position" value:@"{0.5, 0, 0.5, 0}"];
        [frame setProperty:@"size" value:@"{0.5, 0, 0.25, 0}"];
        [frame setProperty:@"cornerRadius" value:@"10"];
        [frame setProperty:@"maskToBounds" value:@"true"];
        
        SWImageElement* image = [SWImageElement newWithParent:frame];
        image.image = [NSImage imageNamed:@"AppIcon"];
        [image setProperty:@"anchorPoint" value:@"{0, 0.5}"];
        [image setProperty:@"position" value:@"{0.05, 0, 0.5, 0}"];
        [image setProperty:@"size" value:@"{0, 0, 0.75, 0}"];
        [image setProperty:@"sizeConstraint" value:@"YY"];

        // [wallpaper.window.contentView.layer addSublayer:frame.layer];

        /* Text
        
        SWTextElement* text = [[SWTextElement alloc] initWithParent:frame];
        text.padding = CGSizeMake(10, 5);
        text.anchorPoint = CGPointMake(0, 0);
        
        NSDateFormatter* formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"E, MMM d, h:mm a"];
        text.layer.string = [formatter stringFromDate: [NSDate now]];

        CGRect imgRect = [image getRect];
        SWRect rect2 = {
            .position = {
                { .scale = 0, .offset = imgRect.size.width + imgRect.origin.x + 15 },
                { .scale = 0, .offset = imgRect.origin.y }
            }
        };
        
        text.frame = rect2;
        text.layer.foregroundColor = NSColor.whiteColor.CGColor;
        text.layer.fontSize = 50;
        text.layer.font = CFBridgingRetain([NSFont boldSystemFontOfSize: text.layer.fontSize]);
        text.layer.alignmentMode = kCAAlignmentCenter;
        [text sizeToFit];
        [frame.layer addSublayer:text.layer];*/
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)sender hasVisibleWindows:(BOOL)flag {
    if (self.uiWindow) {
        [self.uiWindow deminiaturize: self];
    }
    
    return true;
}

@end
