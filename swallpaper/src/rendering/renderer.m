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
        self.window.contentView.wantsLayer = YES;
        self.window.contentView.layer = self.layer;

        self.commandQueue = [[Renderer device] newCommandQueue];
        self.renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];

        self.colorAttachmentDescriptor = [[self.renderPassDescriptor colorAttachments] objectAtIndexedSubscript:0];
        self.colorAttachmentDescriptor.clearColor = MTLClearColorMake(0, 0, 0, 1);
        self.colorAttachmentDescriptor.loadAction = MTLLoadActionClear;
        self.colorAttachmentDescriptor.storeAction = MTLStoreActionStore;
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
        NSWindow* window = [[NonConstrainedNSWindow alloc] initWithContentRect: screen.frame styleMask: NSWindowStyleMaskBorderless backing: NSBackingStoreBuffered defer: NO screen:screen];
        window.hasShadow = NO;
        window.level = kCGDesktopWindowLevel;
        self.info = [RendererInfo newWithWindow:window];
        
        MenuBarWindow* menuBarWindow = [MenuBarWindow newWithMenuBarHandler:[Renderer menuBarHandler] screen:screen];
        self.menuBarInfo = [RendererInfo newWithWindow:menuBarWindow];
        
        MenuBarHandler* handler = [Renderer menuBarHandler];
        CGRect leftMenuBarRect = [handler getLeftMenuBarRect];
        CGRect rightMenuBarRect = [handler getRightMenuBarRect];

        [menuBarWindow updatePositionAndSize: &leftMenuBarRect rightRect:&rightMenuBarRect];
        
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
    self.menuBarInfo.colorAttachmentDescriptor.texture = menuBarDrawable.texture;
    
    id<MTLCommandBuffer> commandBuffer = [self.info.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor: self.info.renderPassDescriptor];
    
    id<MTLCommandBuffer> menuBarCommandBuffer = [self.menuBarInfo.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> menuBarEncoder = [menuBarCommandBuffer renderCommandEncoderWithDescriptor: self.menuBarInfo.renderPassDescriptor];
    
    if (self.videoDecoder != nil) {
        video_decoder_decode_next_frame(self.videoDecoder);
        [VideoRenderer renderWithVideoDecoder:self.videoDecoder encoder:encoder menuBarEncoder:menuBarEncoder];
    }

    [encoder endEncoding];
    [commandBuffer commit];
    [commandBuffer waitUntilScheduled];

    [menuBarEncoder endEncoding];
    [menuBarCommandBuffer commit];
    [menuBarCommandBuffer waitUntilScheduled];
    
    [drawable present];
    [menuBarDrawable present];
}

@end
