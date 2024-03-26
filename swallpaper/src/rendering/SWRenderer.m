#import <Foundation/Foundation.h>
#import <rendering/SWRenderer.h>
#import <QuartzCore/QuartzCore.h>
#import <rendering/SWVideoRenderer.h>
#import <SWGradientLayer.h>

@implementation SWRendererInfo

- (instancetype)initWithWindow: (NSWindow*)window {
    self = [super init];
    
    if (self) {
        self.layer = [[CAMetalLayer alloc] init];
        self.layer.device = [SWRenderer device];
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
        
        self.commandQueue = [[SWRenderer device] newCommandQueue];
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

@implementation SWRenderer

- (instancetype)initWithWallpaper:(SWWallpaper*)wallpaper {
    self = [super init];
    
    if (self) {
        self.info = [SWRendererInfo newWithWindow:wallpaper.window];
        self.menuBarInfo = [SWRendererInfo newWithWindow:wallpaper.menuBar];
    }
    
    return self;
}

+ (instancetype)newWithWallpaper:(SWWallpaper*)wallpaper {
    return [[self alloc] initWithWallpaper:wallpaper];
}

+ (id<MTLDevice>)device {
    static id<MTLDevice> device = nil;
    
    if (device == nil) {
        device = MTLCreateSystemDefaultDevice();
    }
    
    return device;
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
        [SWVideoRenderer render:self];
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
