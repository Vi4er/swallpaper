#pragma once
#import <AppKit/AppKit.h>
#import <MetalKit/MetalKit.h>
#import <decoding/videoDecoder.h>
#import <SWWallpaper.h>

extern NSString* RendererDevice;

@interface SWRendererInfo : NSObject

@property NSWindow* window;
@property CAMetalLayer* layer;
@property id<MTLCommandQueue> commandQueue;
@property MTLRenderPassDescriptor* renderPassDescriptor;
@property MTLRenderPassColorAttachmentDescriptor* colorAttachmentDescriptor;
@property id<MTLRenderCommandEncoder> encoder;
@property MTLViewport viewport;

- (instancetype)initWithWindow:(NSWindow*)window;
+ (instancetype)newWithWindow:(NSWindow*)window;

@end

@interface SWRenderer : NSObject

@property SWRendererInfo* info;
@property SWRendererInfo* menuBarInfo;
@property (nonatomic) VideoDecoder* videoDecoder;

- (instancetype)initWithWallpaper:(SWWallpaper*)wallpaper;
+ (instancetype)newWithWallpaper:(SWWallpaper*)wallpaper;

+ (id<MTLDevice>)device;

- (void)render;

@end
