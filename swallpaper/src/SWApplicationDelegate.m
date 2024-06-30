#import <SWApplicationDelegate.h>
#import <SWWallpaper.h>
#import <SWGradientLayer.h>
#import <scripting/SWElementParser.h>
#import <elements/SWImageElement.h>
#import <elements/SWTextElement.h>
#import <elements/SWEventHandler.h>
#import <CoreImage/CoreImage.h>
#import <scripting/lua.h>

@implementation SWApplicationDelegate

SWWallpaper* wallpaper;
SWElement* element;
lua_State* L;

- (void)reloadWidget {
    if (element) {
        element.parent = nil;
    }
    
    if ((element = [SWElementParser parseFile:@"/Users/user/Documents/swallpaper/swallpaper/Widget.xml"]) != nil) {
        element.parent = wallpaper;
//        CIFilter* filter = [CIFilter filterWithName:@"CIGaussianBlur" withInputParameters:@{
//            kCIInputRadiusKey: @0
//        }];
//        element.layer.backgroundFilters = @[filter];
        
//        if (luaL_dofile(SWLuaState, "/Users/user/Documents/swallpaper/swallpaper/Widget.lua") != LUA_OK) {
//            NSLog(@"Error executing file: %s\n", lua_tostring(SWLuaState, -1));
//        }
        
        NSLog(@"Reloaded widget\n");
    }
}

- (void)monitorFile:(NSString*)path {
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
    
//    [self reloadWidget];

    [wallpaper setScene: @"scene.swal"];
    [wallpaper setFps:60];
    [wallpaper start];

//    [self monitorFile:@"/Users/user/Documents/swallpaper/swallpaper/Widget.xml"];
//    [self monitorFile:@"/Users/user/Documents/swallpaper/swallpaper/Widget.lua"];

//    [SWEventHandler init];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)sender hasVisibleWindows:(BOOL)flag {    
    return true;
}

@end
