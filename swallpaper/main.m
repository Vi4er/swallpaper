#import <SWApplicationDelegate.h>
#import <SWScene.h>
#import <scripting/types/SWElement.h>
#import <elements/SWTextElement.h>
#import <scripting/lua.h>
#import <scripting/types/SWLuaTypes.h>

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* application = [NSApplication sharedApplication];
        NSApp.activationPolicy = NSApplicationActivationPolicyAccessory;

        SWInitLua();
        
        // TODO: Make menu bar completely fluent before moving back to widgets
        
//        SWScene* scene = [[SWScene alloc] init];
//        scene.name = @"Test";
//        scene.desc = @"Test Video";
//
//        SWSceneVideo video = {0};
//        video.filePath = "/Users/user/Downloads/4779866-hd_1920_1080_30fps.mp4";
//        video.fps = 30;
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
        [application setDelegate: appDelegate];
        [application run];
    }
    
    return 0;
}

