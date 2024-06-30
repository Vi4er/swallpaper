#import <rendering/SWVideoRenderer.h>
#import <rendering/SWRenderer.h>

typedef struct {
    simd_packed_float2 position;
    simd_packed_float2 texCoord;
} VertexIn;

@implementation SWRenderer (SWVideoRenderer)

+ (id<MTLRenderPipelineState>)pipelineState {
    static id<MTLRenderPipelineState> pipelineState = nil;
    
    if (pipelineState == nil) {
        NSError* error;
        id<MTLLibrary> library = [[SWRenderer device] newDefaultLibrary];
        
        if (error) {
            NSLog(@"Failed to load shaders %@\n", error);
            return nil;
        }
        
        MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineDescriptor.vertexFunction = [library newFunctionWithName: @"hwvideoVertex"];
        pipelineDescriptor.fragmentFunction = [library newFunctionWithName: @"hwvideoFragment"];
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        MTLVertexDescriptor* vertexDescriptor = [[MTLVertexDescriptor alloc] init];
        
        vertexDescriptor.attributes[0].format = MTLVertexFormatFloat2;
        vertexDescriptor.attributes[0].offset = 0;
        vertexDescriptor.attributes[0].bufferIndex = 0;
        
        vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
        vertexDescriptor.attributes[1].offset = sizeof(float) * 2;
        vertexDescriptor.attributes[1].bufferIndex = 0;
        
        vertexDescriptor.layouts[0].stride = sizeof(float) * 4;
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor;
        
        pipelineState = [[SWRenderer device] newRenderPipelineStateWithDescriptor: pipelineDescriptor error:&error];
        
        if (error != nil) {
            NSLog(@"%@", error);
            return nil;
        }
    }
    
    return pipelineState;
}

+ (id<MTLBuffer>)vertexBuffer {
    static id<MTLBuffer> vertexBuffer = nil;
    
    if (vertexBuffer == nil) {
        VertexIn vertices[] = {
            {{-1.0,  1.0}, {0.0, 0.0}},
            {{ 1.0,  1.0}, {1.0, 0.0}},
            {{-1.0, -1.0}, {0.0, 1.0}},
            {{ 1.0, -1.0}, {1.0, 1.0}},
        };
        
        vertexBuffer = [[SWRenderer device] newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
    }
    
    return vertexBuffer;
}

- (void)decodeNextFrame {
    video_decoder_decode_next_frame(self.videoDecoder);

    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)self.videoDecoder->frame->data[3];
    IOSurfaceRef surface = CVPixelBufferGetIOSurface(pixelBuffer);
    
    if (surface == nil) {
        return;
    }

    self.luminanceTexture = [self.luminanceTextureCache get:surface];
    self.chrominanceTexture = [self.chrominanceTextureCache get:surface];
}

- (void)drawWithEncoder:(id<MTLRenderCommandEncoder>)encoder {
    [encoder setViewport:self.viewport];
    [encoder setRenderPipelineState:[[self class] pipelineState]];
    [encoder setVertexBuffer:[[self class] vertexBuffer] offset:0 atIndex:0];
    [encoder setFragmentTexture:self.luminanceTexture atIndex:0];
    [encoder setFragmentTexture:self.chrominanceTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
}

@end

