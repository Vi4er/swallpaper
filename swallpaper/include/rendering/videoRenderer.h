#import <videoDecoder.h>
#import <MetalKit/MetalKit.h>

@interface VideoRenderer : NSObject

+ (id<MTLRenderPipelineState>)pipelineState;
+ (id<MTLBuffer>)vertexBuffer;

+ (void)renderWithVideoDecoder: (VideoDecoder*)decoder encoder: (id<MTLRenderCommandEncoder>)encoder;

@end
