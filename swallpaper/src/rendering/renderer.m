#import <Foundation/Foundation.h>
#import <rendering/renderer.h>
#import <QuartzCore/QuartzCore.h>
#import <rendering/videoRenderer.h>

@implementation RendererInfo

- (instancetype)initWithWindow: (NSWindow*)window {
    self = [super init];
    
    if (self) {
        self.layer = [[CAMetalLayer alloc] init];
        self.layer.device = [Renderer device];
        self.layer.drawableSize = window.frame.size;
        self.layer.presentsWithTransaction = YES;
        self.layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        self.window = window;
        
        if (self.window.contentView.layer != nil) {
            self.layer.frame = self.window.contentView.layer.frame;
            [self.window.contentView.layer addSublayer: self.layer];
        }
        else {
            self.window.contentView.wantsLayer = YES;
            self.window.contentView.layer = self.layer;
        }
        
        self.commandQueue = [[Renderer device] newCommandQueue];
        self.renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
        
        self.colorAttachmentDescriptor = [[self.renderPassDescriptor colorAttachments] objectAtIndexedSubscript:0];
        self.colorAttachmentDescriptor.clearColor = MTLClearColorMake(0, 0, 0, 1);
        self.colorAttachmentDescriptor.loadAction = MTLLoadActionClear;
        self.colorAttachmentDescriptor.storeAction = MTLStoreActionStore;
        
        MTLViewport viewport = {
            0, 0,
            self.window.frame.size.width,
            self.window.frame.size.height,
            -1.0,
            1.0
        };

        self.viewport = viewport;
    }
    
    return self;
}

+ (instancetype)newWithWindow: (NSWindow*)window {
    return [[self alloc] initWithWindow: window];
}

@end

@implementation Renderer

- (instancetype)initWithScreen:(NSScreen*) screen {
    self = [super init];
    
    if (self) {
        NSWindow* window = [[NonConstrainedNSWindow alloc] initWithContentRect: screen.frame
                                                                     styleMask: NSWindowStyleMaskBorderless
                                                                       backing: NSBackingStoreBuffered
                                                                         defer: NO
                                                                        screen: screen];
        window.hasShadow = NO;
        window.level = kCGDesktopWindowLevel;
        window.backgroundColor = [NSColor clearColor];
        self.info = [RendererInfo newWithWindow:window];
        
        MenuBarWindow* menuBarWindow = [MenuBarWindow newWithMenuBarHandler:[Renderer menuBarHandler] screen:screen];
        self.menuBarInfo = [RendererInfo newWithWindow:menuBarWindow];
        
        MenuBarHandler* handler = [Renderer menuBarHandler];
        CGRect leftMenuBarRect = [handler getLeftMenuBarRect];
        CGRect rightMenuBarRect = [handler getRightMenuBarRect];
        
        [menuBarWindow updatePositionAndSize: &leftMenuBarRect rightRect:&rightMenuBarRect];
        
        // Gradient test
        NSColor* startColor = [NSColor colorWithCalibratedRed:1 green:0 blue:1 alpha:0.5];
        NSColor* endColor = [NSColor colorWithCalibratedRed:0 green:1 blue:1 alpha:0.5];
        NSArray* colors = @[(id)[startColor CGColor], (id)[endColor CGColor]];
        CGPoint startPoint = CGPointMake(0, 0);
        CGPoint endPoint = CGPointMake(1, 0);
//        [menuBarWindow setGradient: colors startPoint:startPoint endPoint:endPoint];
        
        // Fade in
        
        window.alphaValue = menuBarWindow.alphaValue = 0;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext* context) {
            [context setDuration:0.75];
            [[window animator] setAlphaValue:1];
            [[menuBarWindow animator] setAlphaValue:1];
        } completionHandler:nil];
    
        [window orderFront: window];
        
    }
    
    return self;
}

+ (instancetype)newWithScreen:(NSScreen*) screen {
    return [[self alloc] initWithScreen:screen];
}

+ (id<MTLDevice>)device {
    static id<MTLDevice> device = nil;
    
    if (device == nil) {
        device = MTLCreateSystemDefaultDevice();
    }
    
    return device;
}

+ (MenuBarHandler*)menuBarHandler {
    static MenuBarHandler* handler = nil;
    
    if (handler == nil) {
        handler = [[MenuBarHandler alloc] init];
    }
    
    return handler;
}

- (void)render {
    id<CAMetalDrawable> drawable = [self.info.layer nextDrawable];
    id<CAMetalDrawable> menuBarDrawable = [self.menuBarInfo.layer nextDrawable];
    
    if (!drawable || !menuBarDrawable) {
        return;
    }
    
    self.info.colorAttachmentDescriptor.texture = drawable.texture;
    id<MTLCommandBuffer> commandBuffer = [self.info.commandQueue commandBuffer];
    self.info.encoder = [commandBuffer renderCommandEncoderWithDescriptor: self.info.renderPassDescriptor];
    
    self.menuBarInfo.colorAttachmentDescriptor.texture = menuBarDrawable.texture;
    id<MTLCommandBuffer> menuBarCommandBuffer = [self.menuBarInfo.commandQueue commandBuffer];
    self.menuBarInfo.encoder = [menuBarCommandBuffer renderCommandEncoderWithDescriptor: self.menuBarInfo.renderPassDescriptor];
    
    if (self.videoDecoder != nil) {
        video_decoder_decode_next_frame(self.videoDecoder);
        [VideoRenderer render:self];
    }
    
    [self.info.encoder endEncoding];
    [commandBuffer commit];
    [commandBuffer waitUntilScheduled];
    
    [self.menuBarInfo.encoder endEncoding];
    [menuBarCommandBuffer commit];
    [menuBarCommandBuffer waitUntilScheduled];
    
    [drawable present];
    [menuBarDrawable present];
}

@end
