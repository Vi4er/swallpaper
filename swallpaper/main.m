#import <SWApplicationDelegate.h>
#import <SWScene.h>
#import "swallpaper-Swift.h"

#import <elements/SWTextElement.h>

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* application = [NSApplication sharedApplication];
        NSApp.activationPolicy = NSApplicationActivationPolicyAccessory;

        UI* ui = [[UI alloc] init];
        [ui show];

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
