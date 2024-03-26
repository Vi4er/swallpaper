#import <SWApplicationDelegate.h>
#import <SWScene.h>
#import "swallpaper-Swift.h"

@class UI;

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* application = [NSApplication sharedApplication];
        NSApp.activationPolicy = NSApplicationActivationPolicyAccessory;

        UI* ui = [[UI alloc] init];
        [ui show];
        
        SWScene* scene = [[SWScene alloc] init];
        scene.name = @"Pikachu";
        scene.desc = @"Pikachu Rain Video";
        
        SWSceneVideo video = {0};
        video.filePath = "/Users/user/Downloads/wallpaper.mp4";
        video.fps = 60;
        video.playbackSpeed = 1;
        scene.video = video;
        
        SWSceneMenuBarInfo menuBarInfo = {0};
        menuBarInfo.enabled = 1;
        menuBarInfo.colors = @[
            NSColor.grayColor,
            NSColor.grayColor,
            NSColor.whiteColor,
            NSColor.grayColor,
            NSColor.grayColor
        ];
        menuBarInfo.effect = kSWGradientEffectWave;
        scene.menuBarInfo = menuBarInfo;
        
        [scene export: @"/users/user/desktop/scene.swal"];

        SWApplicationDelegate* appDelegate = [[SWApplicationDelegate alloc] init];
        appDelegate.uiWindow = ui.window;
        [application setDelegate: appDelegate];
        [application run];
        
        // video_decoder_free(appDelegate.renderer.videoDecoder);
    }
    
    return 0;
}
