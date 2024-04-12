#import <SWApplicationDelegate.h>
#import <SWScene.h>
#import "swallpaper-Swift.h"
#import <scripting/types/SWElement.h>
#import <elements/SWTextElement.h>
#import <scripting/lua.h>

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* application = [NSApplication sharedApplication];
        NSApp.activationPolicy = NSApplicationActivationPolicyAccessory;

        SWInitLua();

        SWApplicationDelegate* appDelegate = [[SWApplicationDelegate alloc] init];
        [application setDelegate: appDelegate];
        [application run];
    }
    
    return 0;
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
