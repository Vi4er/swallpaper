#import <SWWallpaper.h>
#import <rendering/SWRenderer.h>

@implementation SWWallpaper

@synthesize screen = _screen;
int _fps = 30.0;

SWRenderer* renderer;
NSThread* renderThread = nil;
NSRunLoop* runLoop;
NSTimer* timer;

- (void)setVideo:(NSString*)path {
    NSString* videoPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    renderer.videoDecoder = video_decoder_new([videoPath cStringUsingEncoding:NSUTF8StringEncoding], 1);
}

- (void)renderLoop {
    video_decoder_decode_next_frame(renderer.videoDecoder);
    [renderer render];
}

- (void)renderThreadEntryPoint:(id)object {
    @autoreleasepool {
        runLoop = [NSRunLoop currentRunLoop];
        timer = [NSTimer timerWithTimeInterval:1.0 / _fps
                                        target:self
                                      selector:@selector(renderLoop)
                                      userInfo:nil
                                       repeats:YES];
        
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

- (void)start {
    if (renderThread == nil) {
        renderThread = [[NSThread alloc] initWithTarget:self selector:@selector(renderThreadEntryPoint:) object:nil];
        [renderThread start];
    }
}

- (void)setFps:(int)fps {
    _fps = fps;
    
    if (renderThread == nil) {
        return;
    }
    
    // Restart timer with new fps
    [timer invalidate];
    timer = [NSTimer timerWithTimeInterval:1.0 / _fps
                                    target:self
                                  selector:@selector(renderLoop)
                                  userInfo:nil
                                   repeats:YES];

    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (int)fps {
    return _fps;
}

- (instancetype)initWithScreen:(NSScreen*)screen {
    self = [super init];
    
    if (self) {
        _screen = screen;
        renderer = [SWRenderer newWithScreen:screen];
    }
    
    return self;
}

+ (instancetype)newWithScreen:(NSScreen*)screen {
    return [[self alloc] initWithScreen:screen];
}

@end
