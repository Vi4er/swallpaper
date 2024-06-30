#import <SWWallpaper.h>
#import <SWGradientLayer.h>
#import <SWFlippedView.h>
#import <rendering/SWRenderer.h>
#import <SWScene.h>

@implementation SWWallpaper

int _fps = 30.0;

NSThread* renderThread = nil;
NSRunLoop* runLoop;
NSTimer* timer;

+ (NSMutableArray<SWWallpaper*>*)wallpapers {
    static NSMutableArray<SWWallpaper*>* wallpapers;
    
    if (wallpapers == nil) {
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(screenUpdate:)
                                                     name:NSApplicationDidChangeScreenParametersNotification
                                                   object:nil];
        
        // TOOD: Make this do stuff
        /*AXObserverRef observer;
        if (AXObserverCreate(37544, accessibilityCallback, &observer) != kAXErrorSuccess) {
            NSLog(@"???\n");
        }
        else {
            AXObserverAddNotification(observer, AXUIElementCreateApplication(37544), kAXWindowCreatedNotification, NULL);
            CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
        }*/
    }
    
    return wallpapers;
}

/*static void accessibilityCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void *context) {
    // Check for window creation event
    if (CFStringCompare(notificationName, kAXWindowCreatedNotification, 0) == kCFCompareEqualTo) {
        NSLog(@"Window created");
        NSRect leftMenuBarRect = [SWMenuBar getLeftMenuBarRect];
        NSRect rightMenuBarRect = [SWMenuBar getRightMenuBarRect];

        if (leftMenuBarRect.origin.x == -1) {
            return;
        }

        for (SWWallpaper* wallpaper in [SWWallpaper wallpapers]) {
            [wallpaper.menuBar updatePositionAndSize:&leftMenuBarRect rightRect:&rightMenuBarRect];
        }
    }
}*/

- (void)setScene:(NSString*)path {
    path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    
    if (self.renderer.videoDecoder) {
        video_decoder_free(self.renderer.videoDecoder);
    }
    
    SWScene* scene = [SWScene import:path];
    self.renderer.videoDecoder = video_decoder_new(scene_aviocontext_new([path cStringUsingEncoding:NSUTF8StringEncoding], scene.video.dataLocation, scene.video.dataLength), 1);
    [self setFps: scene.video.fps];

    if (scene.menuBarInfo.enabled) {
        NSMutableArray* colors = [NSMutableArray array];

        for (NSColor* color in scene.menuBarInfo.colors) {
            if (color.alphaComponent == 0) {
                [colors addObject: color];
            }
            else {
                [colors addObject:(id)[color colorWithAlphaComponent:0.5].CGColor];
            }
        }

        [self.menuBar setGradient:(NSArray*)colors startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
        [(SWGradientLayer*)self.menuBar.contentView.layer setEffect: scene.menuBarInfo.effect];
    }
    else {
        [self.menuBar setGradient:@[(id)NSColor.clearColor] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
        [(SWGradientLayer*)self.menuBar.contentView.layer setEffect: kSWGradientEffectNone];
    }
}

- (void)renderLoop {
    [self.renderer render];
}

- (void)renderThreadEntryPoint:(id)object {
    @autoreleasepool {
        // TODO: Possibly switch to CAMetalDisplayLink
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
        _menuBar = [SWMenuBar newWithScreen:screen];

        
        // Window

        _window = [[SWNonConstrainedWindow alloc] initWithContentRect:screen.frame
                                                            styleMask:NSWindowStyleMaskBorderless|NSWindowStyleMaskNonactivatingPanel
                                                              backing:NSBackingStoreBuffered
                                                                defer:NO
                                                               screen:screen];
        _window.hasShadow = NO;
        _window.level = kCGDesktopWindowLevel;
        _window.backgroundColor = [NSColor clearColor];
        _window.contentView = [[SWFlippedView alloc] init];
        
        // Fade
        
        _window.alphaValue = _menuBar.alphaValue = 0;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
            [context setDuration:0.75];
            [[_window animator] setAlphaValue:1];
            [[_menuBar animator] setAlphaValue:1];
        } completionHandler:nil];
    
        [_window orderFront: nil];
        
        _renderer = [SWRenderer newWithWallpaper:self];
        
        [[SWWallpaper wallpapers] addObject:self];
    }
    
    return self;
}

+ (instancetype)newWithScreen:(NSScreen*)screen {
    return [[self alloc] initWithScreen:screen];
}

+ (void)appDidActivate:(NSNotification*)notification {
    NSRunningApplication* runningApp = notification.userInfo[NSWorkspaceApplicationKey];

    if (runningApp.processIdentifier == [NSRunningApplication currentApplication].processIdentifier) {
        return;
    }
    
    NSRect leftMenuBarRect = [SWMenuBar getLeftMenuBarRect];
    NSRect rightMenuBarRect = [SWMenuBar getRightMenuBarRect];

    if (leftMenuBarRect.origin.x == -1) {
        return;
    }

    for (SWWallpaper* wallpaper in [SWWallpaper wallpapers]) {
        [wallpaper.menuBar updatePositionAndSize:&leftMenuBarRect rightRect:&rightMenuBarRect];
    }
}

// TODO: Make more fluent
+ (void)screenUpdate:(NSNotification*)notification {
    NSRect leftMenuBarRect = [SWMenuBar getLeftMenuBarRect];
    NSRect rightMenuBarRect = [SWMenuBar getRightMenuBarRect];

    if (leftMenuBarRect.origin.x == -1) {
        return;
    }

    for (SWWallpaper* wallpaper in [SWWallpaper wallpapers]) {
        wallpaper.renderer.menuBarInfo.layer.drawableSize = wallpaper.menuBar.frame.size;
        wallpaper.renderer.info.layer.drawableSize = wallpaper.window.screen.frame.size;
        [wallpaper.menuBar updatePositionAndSize:&leftMenuBarRect rightRect:&rightMenuBarRect];
        [wallpaper.window setFrame: NSMakeRect(0, 0, wallpaper.window.screen.frame.size.width, wallpaper.window.screen.frame.size.height) display:NO];
        
        MTLViewport viewport = {
            0, 0,
            wallpaper.window.screen.frame.size.width,
            wallpaper.window.screen.frame.size.height,
            -1.0,
            1.0
        };
        wallpaper.renderer.viewport = viewport;
    }
}


- (void)dealloc
{
    [[SWWallpaper wallpapers] removeObject:self];
}

@end
