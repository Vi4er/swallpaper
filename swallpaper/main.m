#import <SWApplicationDelegate.h>
#import <SWScene.h>
#import "swallpaper-Swift.h"
#import <scripting/types/Utils.h>
#include <scripting/types/SWElement.h>
#import <elements/SWTextElement.h>

int getProperty(lua_State* L) {
    
    return 0;
}

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* application = [NSApplication sharedApplication];
        NSApp.activationPolicy = NSApplicationActivationPolicyAccessory;

        UI* ui = [[UI alloc] init];
        [ui show];
        
        lua_State* L = luaL_newstate();
        luaL_openlibs(L);
        lua_registerSWTypes(L);

        SWElement* testElement = [SWElement new];
        testElement.frame.origin = [SWPoint newWithX:[SWScaled newWithScale:0.5 offset:0] y:[SWScaled newWithScale:0 offset:100]];
        lua_pushSWElement(L, testElement);
        lua_setglobal(L, "test");
        
        lua_pushcfunction(L, getProperty);
        lua_setglobal(L, "getProperty");
        
        if (luaL_dofile(L, "/Users/user/Documents/swallpaper/swallpaper/test.lua") != LUA_OK) {
            NSLog(@"Error executing file: %s\n", lua_tostring(L, -1));
        }

//        SWScene* scene = [[SWScene alloc] init];
//        scene.name = @"Car";
//        scene.desc = @"Car Video";
//
//        SWSceneVideo video = {0};
//        video.filePath = "/Users/user/Downloads/output.mp4";
//        video.fps = 60;
//        video.playbackSpeed = 1;
//        scene.video = video;
//
//        SWSceneMenuBarInfo menuBarInfo = {0};
//        menuBarInfo.enabled = 1;
//        menuBarInfo.colors = @[
//            NSColor.clearColor,
//            NSColor.clearColor,
//            NSColor.whiteColor,
//            NSColor.clearColor,
//            NSColor.clearColor
//        ];
//        menuBarInfo.effect = kSWGradientEffectWave;
//        scene.menuBarInfo = menuBarInfo;
//
//        [scene export: @"/Users/user/Documents/swallpaper/swallpaper/scene.swal"];

        SWApplicationDelegate* appDelegate = [[SWApplicationDelegate alloc] init];
        appDelegate.uiWindow = ui.window;
        [application setDelegate: appDelegate];
        [application run];
    }
    
    return 0;
}
