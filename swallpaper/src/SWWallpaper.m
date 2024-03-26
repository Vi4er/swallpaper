#import <SWWallpaper.h>
#import <SWGradientLayer.h>
#import <rendering/SWRenderer.h>
#import <SWScene.h>

@implementation SWWallpaper

static NSMutableArray<SWWallpaper*>* wallpapers;

int _fps = 30.0;

SWRenderer* renderer;
NSThread* renderThread = nil;
NSRunLoop* runLoop;
NSTimer* timer;

- (void)setScene:(NSString*)path {
    // path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    
    if (renderer.videoDecoder) {
        video_decoder_free(renderer.videoDecoder);
    }
    
    SWScene* scene = [SWScene import:path];
    renderer.videoDecoder = video_decoder_new(scene_aviocontext_new([path cStringUsingEncoding:NSUTF8StringEncoding], scene.video.dataLocation, scene.video.dataLength), 1);
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
        _menuBar = [SWMenuBar newWithScreen:screen];

        
        // Window

        _window = [[SWNonConstrainedWindow alloc] initWithContentRect:screen.frame
                                                            styleMask:NSWindowStyleMaskBorderless
                                                              backing:NSBackingStoreBuffered
                                                                defer:NO
                                                               screen:screen];
        _window.hasShadow = NO;
        _window.level = kCGDesktopWindowLevel;
        _window.backgroundColor = [NSColor clearColor];
        
        // Fade
        
        _window.alphaValue = _menuBar.alphaValue = 0;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
            [context setDuration:0.75];
            [[_window animator] setAlphaValue:1];
            [[_menuBar animator] setAlphaValue:1];
        } completionHandler:nil];
    
        [_window orderFront: nil];
        
        renderer = [SWRenderer newWithWallpaper:self];
        
        if (!wallpapers) {
            wallpapers = [NSMutableArray array];
            
            NSNotificationCenter* notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];

            [notificationCenter addObserver:self
                                    selector:@selector(appDidActivate:)
                                    name:NSWorkspaceDidActivateApplicationNotification
                                    object:nil];
            
            [notificationCenter addObserver:self
                                    selector:@selector(appDidActivate:)
                                    name:NSWorkspaceDidLaunchApplicationNotification
                                    object:nil];
        }
        
        [wallpapers addObject:self];
    }
    
    return self;
}

+ (instancetype)newWithScreen:(NSScreen*)screen {
    return [[self alloc] initWithScreen:screen];
}

- (void)appDidActivate:(NSNotification *)notification {
    NSRect leftMenuBarRect = [SWMenuBar getLeftMenuBarRect];
    NSRect rightMenuBarRect = [SWMenuBar getRightMenuBarRect];

    if (leftMenuBarRect.origin.x == -1) {
        return;
    }

    for (int i = 0; i < wallpapers.count; ++i) {
        [wallpapers[i].menuBar updatePositionAndSize:&leftMenuBarRect rightRect:&rightMenuBarRect];
    }
}

- (void)dealloc
{
    [wallpapers removeObject:self];
}

@end
