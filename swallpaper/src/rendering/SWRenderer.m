#import <Foundation/Foundation.h>
#import <rendering/SWRenderer.h>
#import <QuartzCore/QuartzCore.h>
#import <rendering/SWVideoRenderer.h>
#import <SWGradientLayer.h>
#import <SWWallpaper.h>

@implementation SWTextureCache

- (instancetype)initWithRenderer:(SWRenderer*)renderer plane:(int)plane {
    self = [super init];
    
    if (self) {
        self.renderer = renderer;
        self.plane = plane;
        self.textures = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id<MTLTexture>)get:(IOSurfaceRef)surface {
    if (self.textureDescriptor == nil) {
        self.textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:self.plane == 0 ? MTLPixelFormatR8Unorm : MTLPixelFormatRG8Unorm
                                                                                    width:self.renderer.videoDecoder->frame->width / (self.plane + 1)
                                                                                   height:self.renderer.videoDecoder->frame->height / (self.plane + 1)
                                                                                mipmapped:NO];
        self.textureDescriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
    }
    
    NSNumber* key = [NSNumber numberWithInt:IOSurfaceGetID(surface)];
    id<MTLTexture> texture = [self.textures objectForKey:key];

    if (texture == nil) {
        texture = [[SWRenderer device] newTextureWithDescriptor:self.textureDescriptor iosurface:surface plane:self.plane];
        self.textures[key] = texture;
    }
    
    return texture;
}

- (void)reset {
    self.textureDescriptor = nil;
    self.textures = [NSMutableDictionary dictionary];
}

@end

// TODO: Cleanup this class
@implementation SWRendererInfo

- (instancetype)initWithWindow:(NSWindow*)window {
    self = [super init];
    
    if (self) {
        self.layer = [CAMetalLayer layer];
        self.layer.device = [SWRenderer device];
        self.layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        self.layer.opaque = NO;

        if (window.contentView.layer != nil) {
            self.layer.frame = window.contentView.layer.frame;
            [window.contentView.layer addSublayer: self.layer];
        }
        else {
            window.contentView.wantsLayer = YES;
            window.contentView.layer = self.layer;
        }
        
        self.renderPassDescriptor = [MTLRenderPassDescriptor new];
        
        self.colorAttachmentDescriptor = self.renderPassDescriptor.colorAttachments[0];
        self.colorAttachmentDescriptor.clearColor = MTLClearColorMake(0, 0, 0, 1);
        self.colorAttachmentDescriptor.loadAction = MTLLoadActionClear;
        self.colorAttachmentDescriptor.storeAction = MTLStoreActionStore;
    }
    
    return self;
}

+ (instancetype)newWithWindow:(NSWindow*)window {
    return [[self alloc] initWithWindow: window];
}

- (id<CAMetalDrawable>)nextDrawable {
    id<CAMetalDrawable> drawable = [self.layer nextDrawable];

    if (drawable) {
        self.colorAttachmentDescriptor.texture = drawable.texture;
    }
    
    return drawable;
}

@end

@implementation SWRenderer

@synthesize videoDecoder = _videoDecoder;

// TODO: Cleanup the update code for menu bar (updating with rects)
- (instancetype)initWithWallpaper:(SWWallpaper*)wallpaper {
    self = [super init];
    
    if (self) {
        self.info = [SWRendererInfo newWithWindow:wallpaper.window];
        self.menuBarInfo = [SWRendererInfo newWithWindow:wallpaper.menuBar];
        self.commandQueue = [[SWRenderer device] newCommandQueue];

        self.luminanceTextureCache = [[SWTextureCache alloc] initWithRenderer:self plane:0];
        self.chrominanceTextureCache = [[SWTextureCache alloc] initWithRenderer:self plane:1];

        MTLViewport viewport = {
            0, 0,
            wallpaper.window.screen.frame.size.width,
            wallpaper.window.screen.frame.size.height,
            -1.0,
            1.0
        };

        self.viewport = viewport;
        
        NSRect leftMenuBarRect = [SWMenuBar getLeftMenuBarRect];
        NSRect rightMenuBarRect = [SWMenuBar getRightMenuBarRect];
        [wallpaper.menuBar updatePositionAndSize:&leftMenuBarRect rightRect:&rightMenuBarRect];
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
    id<CAMetalDrawable> mainDrawable = [self.info nextDrawable], menuBarDrawable = [self.menuBarInfo nextDrawable];
    
    if (!mainDrawable || !menuBarDrawable) {
        return;
    }
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    if (self.videoDecoder != nil) {
        [self decodeNextFrame];
        
        id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor: self.info.renderPassDescriptor];
        [self drawWithEncoder:encoder];
        [encoder endEncoding];

        encoder = [commandBuffer renderCommandEncoderWithDescriptor: self.menuBarInfo.renderPassDescriptor];
        [self drawWithEncoder:encoder];
        [encoder endEncoding];
    }

    [commandBuffer presentDrawable:mainDrawable];
    [commandBuffer presentDrawable:menuBarDrawable];
    
    [commandBuffer commit];
}

-(VideoDecoder*)videoDecoder {
    return _videoDecoder;
}

// TODO: Make sure that this correctly resets when the video decoder is changed, possibly make it so video decoders don't have to recreate everything and can be reset
-(void)setVideoDecoder:(VideoDecoder*)videoDecoder {
    _videoDecoder = videoDecoder;
    [self.luminanceTextureCache reset];
    [self.chrominanceTextureCache reset];
}

@end
