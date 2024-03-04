#import <appDelegate.h>
#import <menuBar.h>

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* application = [NSApplication sharedApplication];

        NSScreen* screen = [NSScreen mainScreen];

        ApplicationDelegate* appDelegate = [[ApplicationDelegate alloc] init];
        appDelegate.renderer = [Renderer newWithScreen:screen];
        appDelegate.renderer.videoDecoder = video_decoder_new("/Users/user/Downloads/video.mp4", 1);
        
        [application setDelegate: appDelegate];
        [application run];
        
        video_decoder_free(appDelegate.renderer.videoDecoder);
    }

    return 0;
}
