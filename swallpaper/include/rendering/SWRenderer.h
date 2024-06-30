#pragma once
#import <AppKit/AppKit.h>
#import <MetalKit/MetalKit.h>
#import <decoding/videoDecoder.h>

@class SWRenderer;
@class SWWallpaper;
extern NSString* RendererDevice;

@interface SWTextureCache : NSObject

@property SWRenderer* renderer;
@property int plane;
@property MTLTextureDescriptor* textureDescriptor;
@property NSMutableDictionary* textures;

- (instancetype)initWithRenderer:(SWRenderer*)renderer plane:(int)plane;
- (id<MTLTexture>)get: (IOSurfaceRef)surface;
- (void)reset;

@end

@interface SWRendererInfo : NSObject

@property CAMetalLayer* layer;
@property MTLRenderPassDescriptor* renderPassDescriptor;
@property MTLRenderPassColorAttachmentDescriptor* colorAttachmentDescriptor;

- (instancetype)initWithWindow:(NSWindow*)window;
+ (instancetype)newWithWindow:(NSWindow*)window;

- (id<CAMetalDrawable>)nextDrawable;

@end

@interface SWRenderer : NSObject

@property SWRendererInfo* info;
@property SWRendererInfo* menuBarInfo;
@property MTLViewport viewport;
@property id<MTLCommandQueue> commandQueue;

@property (nonatomic) VideoDecoder* videoDecoder;
@property SWTextureCache* luminanceTextureCache;
@property SWTextureCache* chrominanceTextureCache;

- (instancetype)initWithWallpaper:(SWWallpaper*)wallpaper;
+ (instancetype)newWithWallpaper:(SWWallpaper*)wallpaper;

+ (id<MTLDevice>)device;

- (void)render;

@end
