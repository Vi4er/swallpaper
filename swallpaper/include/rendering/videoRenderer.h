#import <videoDecoder.h>
#import <rendering/renderer.h>
#import <MetalKit/MetalKit.h>

@interface VideoRenderer : NSObject

+ (id<MTLRenderPipelineState>)pipelineState;
+ (id<MTLBuffer>)vertexBuffer;

+ (void)drawTextureWithEncoder: (id<MTLRenderCommandEncoder>)encoder luminanceTexture:(id<MTLTexture>)luminanceTexture chrominanceTexture:(id<MTLTexture>)chrominanceTexture viewport:(MTLViewport*)viewport;

+ (void)render:(Renderer*)renderer;

@end
