#import <SWApplicationDelegate.h>
#import <SWWallpaper.h>
#import <SWGradientLayer.h>
#import <elements/SWElementParser.h>
#import <elements/SWImageElement.h>
#import <elements/SWTextElement.h>
#import <elements/SWDragEventHandler.h>
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
    
    [SWDragEventHandler registerHandler];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)sender hasVisibleWindows:(BOOL)flag {
    if (self.uiWindow) {
        [self.uiWindow deminiaturize: self];
    }
    
    return true;
}

@end
