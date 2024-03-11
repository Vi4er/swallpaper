#import <appDelegate.h>

@implementation ApplicationDelegate

- (void)mainLoop {
    video_decoder_decode_next_frame(self.renderer.videoDecoder);
    [self.renderer render];
}

- (void)renderThreadEntryPoint:(id)object {
    @autoreleasepool {
        NSTimeInterval targetTime = 1.0 / 30.0;
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:targetTime
                                                 target:self
                                               selector:@selector(mainLoop)
                                               userInfo:nil
                                                repeats:YES];
        
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSScreen *screen = [NSScreen mainScreen];
    self.renderer = [Renderer newWithScreen:screen];

    NSString *videoPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"video.mp4"];
    self.renderer.videoDecoder = video_decoder_new([videoPath cStringUsingEncoding:NSUTF8StringEncoding], 1);

    self.renderThread = [[NSThread alloc] initWithTarget:self selector:@selector(renderThreadEntryPoint:) object:nil];
    [self.renderThread start];
}

@end
