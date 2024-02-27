#import <Foundation/Foundation.h>
#import <rendering/renderer.h>
#import <QuartzCore/QuartzCore.h>
#import <rendering/videoRenderer.h>

@implementation Renderer

- (instancetype)initWithWindow:(NSWindow*) window {
    self = [super init];

    if (self) {
        self.window = window;
        
        self.layer = [[CAMetalLayer alloc] init];
        self.layer.device = [Renderer device];
        self.layer.drawableSize = window.frame.size;
        self.layer.presentsWithTransaction = YES;
        self.layer.pixelFormat = MTLPixelFormatBGRA8Unorm;

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

+ (instancetype)newWithWindow:(NSWindow*) window {
    return [[self alloc] initWithWindow:window];
}

+ (id<MTLDevice>)device {
    static id<MTLDevice> device = nil;
    
    if (device == nil) {
        device = MTLCreateSystemDefaultDevice();
    }
    
    return device;
}

- (void)render {
    id<CAMetalDrawable> drawable = [self.layer nextDrawable];
    
    if (!drawable) {
        return;
    }
    
    self.colorAttachmentDescriptor.texture = drawable.texture;
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor: self.renderPassDescriptor];
    
    if (self.videoDecoder != nil) {
        video_decoder_decode_next_frame(self.videoDecoder);
        [VideoRenderer renderWithVideoDecoder:self.videoDecoder encoder:encoder];
    }
    
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilScheduled];
    [drawable present];
}

@end
