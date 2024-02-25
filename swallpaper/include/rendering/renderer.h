#pragma once
#import <AppKit/AppKit.h>
#import <MetalKit/MetalKit.h>
#import <videoDecoder.h>

extern NSString* RendererDevice;

@interface Renderer : NSObject

@property (nonatomic, strong) NSWindow* window;
@property (nonatomic, strong) CAMetalLayer* layer;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTLRenderPassDescriptor* renderPassDescriptor;
@property (nonatomic, strong) MTLRenderPassColorAttachmentDescriptor* colorAttachmentDescriptor;
@property (nonatomic) VideoDecoder* videoDecoder;

- (instancetype)initWithWindow: (NSWindow*) window;
+ (instancetype)newWithWindow: (NSWindow*) window;

+ (id<MTLDevice>)device;

- (void)render;

@end
