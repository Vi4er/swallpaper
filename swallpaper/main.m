#import <AppKit/AppKit.h>
#include <QuartzCore/QuartzCore.h>
#include <rendering/renderer.h>

@interface ApplicationDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) dispatch_source_t timerSource;
@property Renderer* renderer;

- (void)mainLoop;

@end

@implementation ApplicationDelegate
- (void)mainLoop {
    video_decoder_decode_next_frame(self.renderer.videoDecoder);
    [self.renderer render];
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    NSTimeInterval targetTime = 1.0 / 120.0;
    NSTimer *timer = [NSTimer timerWithTimeInterval:targetTime
                                                 target:self
                                               selector:@selector(mainLoop)
                                               userInfo:nil
                                                repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}
@end

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* application = [NSApplication sharedApplication];

        NSScreen* screen = [NSScreen mainScreen];
        NSWindow* window = [[NSWindow alloc] initWithContentRect: screen.frame styleMask: NSWindowStyleMaskBorderless backing: NSBackingStoreBuffered defer: NO];
        window.level = CGWindowLevelForKey(kCGDesktopWindowLevelKey);
        [window orderFront: window];
        
        ApplicationDelegate* appDelegate = [[ApplicationDelegate alloc] init];

        appDelegate.renderer = [Renderer newWithWindow:window];
        appDelegate.renderer.videoDecoder = video_decoder_new("/Users/user/Downloads/sunset-pink-ocean-moewalls-com.mp4", 1);

        [application setDelegate: appDelegate];
        [application run];
        
        video_decoder_free(appDelegate.renderer.videoDecoder);
    }

    return 0;
}
