#pragma once
#import <AppKit/AppKit.h>
#import <MetalKit/MetalKit.h>
#import <videoDecoder.h>
#include <menuBar.h>

extern NSString* RendererDevice;

@interface RendererInfo : NSObject

@property NSWindow* window;
@property CAMetalLayer* layer;
@property id<MTLCommandQueue> commandQueue;
@property MTLRenderPassDescriptor* renderPassDescriptor;
@property MTLRenderPassColorAttachmentDescriptor* colorAttachmentDescriptor;
@property id<MTLRenderCommandEncoder> encoder;

- (instancetype)initWithWindow: (NSWindow*)window;
+ (instancetype)newWithWindow: (NSWindow*)window;

@end

@interface Renderer : NSObject

@property RendererInfo* info;
@property RendererInfo* menuBarInfo;
@property (nonatomic) VideoDecoder* videoDecoder;

- (instancetype)initWithScreen: (NSScreen*)screen;
+ (instancetype)newWithScreen: (NSScreen*)screen;

+ (id<MTLDevice>)device;
+ (MenuBarHandler*)menuBarHandler;

- (void)render;

@end
