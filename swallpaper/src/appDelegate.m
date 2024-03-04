#import <appDelegate.h>

@implementation ApplicationDelegate
- (void)mainLoop {
    video_decoder_decode_next_frame(self.renderer.videoDecoder);
    [self.renderer render];
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    NSTimeInterval targetTime = 1.0 / 30.0;
    NSTimer *timer = [NSTimer timerWithTimeInterval:targetTime
                                                 target:self
                                               selector:@selector(mainLoop)
                                               userInfo:nil
                                                repeats:YES];

    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}
@end
