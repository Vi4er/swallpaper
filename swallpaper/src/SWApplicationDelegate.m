#import <SWApplicationDelegate.h>
#import <SWWallpaper.h>
#import <SWGradientLayer.h>
#import <elements/SWElementParser.h>
#import <elements/SWImageElement.h>
#import <elements/SWTextElement.h>
#import "swallpaper-Swift.h"

@implementation SWApplicationDelegate

SWWallpaper* wallpaper;
SWElement* element;

- (void)reloadWidget {
    if (element) {
        element.parent = nil;
    }
    
    if ((element = [SWElementParser parseFile:@"/Users/user/Documents/swallpaper/swallpaper/MediaWidget.xml"]) != nil) {
        element.parent = wallpaper;
        NSLog(@"Reloaded widget\n");
    }
}

- (void)monitorFile:(NSString*) path {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    int descriptor = open([path UTF8String], O_EVTONLY);

    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, descriptor, DISPATCH_VNODE_WRITE, queue);

    dispatch_source_set_event_handler(source, ^{
        if(dispatch_source_get_data(source) & DISPATCH_VNODE_WRITE)
        {
            dispatch_source_cancel(source);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadWidget];
            });

            [self monitorFile:path];
        }
    });

    dispatch_source_set_cancel_handler(source, ^(void) {
        close(descriptor);
    });

    dispatch_resume(source);
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    wallpaper = [SWWallpaper newWithScreen: [NSScreen mainScreen]];
    [wallpaper setScene: @"scene.swal"];
    [wallpaper setFps:60];
    [wallpaper start];

    [self reloadWidget];
    [self monitorFile:@"/Users/user/Documents/swallpaper/swallpaper/MediaWidget.xml"];
        // TODO: Make proper elements API, especially for adding element children (should be able to nest SWTextElement and shit)

        
        // Frame

        /*SWElement* frame = [SWElement newWithParent:wallpaper];
        [frame setProperty:@"backgroundColor" value:@"rgb(0, 0, 0, 127.5)"];
        [frame setProperty:@"anchorPoint" value:@"{0.5, 0.5}"];
        [frame setProperty:@"position" value:@"{0.5, 0, 0.5, 0}"];
        [frame setProperty:@"size" value:@"{0.5, 0, 0.25, 0}"];
        [frame setProperty:@"cornerRadius" value:@"10"];
        [frame setProperty:@"maskToBounds" value:@"true"];
        
        SWImageElement* image = [SWImageElement newWithParent:frame];
        [image setProperty:@"image" value:@"AppIcon"];
        [image setProperty:@"anchorPoint" value:@"{0, 0.5}"];
        [image setProperty:@"position" value:@"{0.05, 0, 0.5, 0}"];
        [image setProperty:@"size" value:@"{0, 0, 0.75, 0}"];
        [image setProperty:@"sizeConstraint" value:@"YY"];*/

        /*SWTextElement* text = [[SWTextElement alloc] initWithParent:element];

        SWRect rect2 = {
            .size = {
                { .scale = 1 },
                { .scale = 1 }
            }
        };

        text.layer.string = @"Syntad";
        text.layer.backgroundColor = NSColor.redColor.CGColor;
        text.layer.foregroundColor = NSColor.whiteColor.CGColor;
        text.layer.fontSize = 50;
        text.layer.font = CFBridgingRetain([NSFont boldSystemFontOfSize: text.layer.fontSize]);
        text.layer.alignmentMode = kCAAlignmentCenter;
        text.frame = rect2;*/
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)sender hasVisibleWindows:(BOOL)flag {
    if (self.uiWindow) {
        [self.uiWindow deminiaturize: self];
    }
    
    return true;
}

@end
