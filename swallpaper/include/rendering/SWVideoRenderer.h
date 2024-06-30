#pragma once
#import <decoding/videoDecoder.h>
#import <MetalKit/MetalKit.h>
#import <rendering/SWRenderer.h>

@interface SWRenderer ()

@property id<MTLTexture> luminanceTexture;
@property id<MTLTexture> chrominanceTexture;

@end

@interface SWRenderer (SWVideoRenderer)

- (void)decodeNextFrame;

- (void)drawWithEncoder:(id<MTLRenderCommandEncoder>)encoder ;

@end
