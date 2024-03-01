#pragma once
#import <AppKit/AppKit.h>
#import <MetalKit/MetalKit.h>
#import <videoDecoder.h>
#include <menuBar.h>

extern NSString* RendererDevice;

@interface RendererInfo : NSObject

@property (nonatomic, strong) NSWindow* window;
@property (nonatomic, strong) CAMetalLayer* layer;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTLRenderPassDescriptor* renderPassDescriptor;
@property (nonatomic, strong) MTLRenderPassColorAttachmentDescriptor* colorAttachmentDescriptor;

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
