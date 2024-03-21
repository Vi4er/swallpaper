#import <decoding/videoDecoder.h>
#import <rendering/SWRenderer.h>
#import <MetalKit/MetalKit.h>

@interface VideoRenderer : NSObject

+ (id<MTLRenderPipelineState>)pipelineState;
+ (id<MTLBuffer>)vertexBuffer;

+ (void)drawTextureWithEncoder: (id<MTLRenderCommandEncoder>)encoder luminanceTexture:(id<MTLTexture>)luminanceTexture chrominanceTexture:(id<MTLTexture>)chrominanceTexture viewport:(MTLViewport)viewport;

+ (void)render:(SWRenderer*)renderer;

@end
