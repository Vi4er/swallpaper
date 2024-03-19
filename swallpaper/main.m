#import <appDelegate.h>
#import <menuBar.h>
#import "swallpaper-Swift.h"

@class UI;

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* application = [NSApplication sharedApplication];
        NSApp.activationPolicy = NSApplicationActivationPolicyAccessory;
        
        UI* ui = [[UI alloc] init];
        [ui show];

        ApplicationDelegate* appDelegate = [[ApplicationDelegate alloc] init];
        appDelegate.uiWindow = ui.window;
        [application setDelegate: appDelegate];
        [application run];
        
        video_decoder_free(appDelegate.renderer.videoDecoder);
    }
    
    return 0;
}
