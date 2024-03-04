#import <rendering/videoRenderer.h>
#import <rendering/renderer.h>

typedef struct {
    simd_packed_float2 position;
    simd_packed_float2 texCoord;
} VertexIn;

@implementation VideoRenderer

+ (id<MTLRenderPipelineState>)pipelineState {
    static id<MTLRenderPipelineState> pipelineState = nil;
    
    if (pipelineState == nil) {
        NSError* error;
        id<MTLLibrary> library = [[Renderer device] newDefaultLibrary];
        
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
        
        pipelineState = [[Renderer device] newRenderPipelineStateWithDescriptor: pipelineDescriptor error:&error];
        
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
        
        vertexBuffer = [[Renderer device] newBufferWithBytes:vertices length:sizeof(vertices) options:MTLResourceStorageModeShared];
    }
    
    return vertexBuffer;
}

+ (void)drawTextureWithEncoder:(id<MTLRenderCommandEncoder>)encoder luminanceTexture:(id<MTLTexture>)luminanceTexture chrominanceTexture:(id<MTLTexture>)chrominanceTexture viewport:(MTLViewport*)viewport {
    [encoder setViewport:*viewport];
    [encoder setRenderPipelineState:[VideoRenderer pipelineState]];
    [encoder setVertexBuffer:[VideoRenderer vertexBuffer] offset:0 atIndex:0];
    [encoder setFragmentTexture:luminanceTexture atIndex:0];
    [encoder setFragmentTexture:chrominanceTexture atIndex:1];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
}

+ (void)render:(Renderer*)renderer {
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)renderer.videoDecoder->frame->data[3];
    IOSurfaceRef surface = CVPixelBufferGetIOSurface(pixelBuffer);
    
    if (surface == nil) {
        return;
    }
    
    MTLTextureDescriptor* luminanceTextureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm
                                                                                                          width:renderer.videoDecoder->frame->width
                                                                                                         height:renderer.videoDecoder->frame->height
                                                                                                      mipmapped:NO];
    luminanceTextureDescriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
    
    MTLTextureDescriptor* chrominanceTextureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRG8Unorm
                                                                                                            width:renderer.videoDecoder->frame->width / 2
                                                                                                           height:renderer.videoDecoder->frame->height / 2
                                                                                                        mipmapped:NO];
    chrominanceTextureDescriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
    
    id<MTLTexture> luminanceTexture = [[Renderer device] newTextureWithDescriptor:luminanceTextureDescriptor iosurface:surface plane:0];
    id<MTLTexture> chrominanceTexture = [[Renderer device] newTextureWithDescriptor:chrominanceTextureDescriptor iosurface:surface plane:1];
    
    MTLViewport viewport = {
        0, 0,
        renderer.info.window.screen.frame.size.width,
        renderer.info.window.screen.frame.size.height,
        -1.0,
        1.0
    };
    
    [self drawTextureWithEncoder:renderer.info.encoder luminanceTexture:luminanceTexture chrominanceTexture:chrominanceTexture viewport:&viewport];
    [self drawTextureWithEncoder:renderer.menuBarInfo.encoder luminanceTexture:luminanceTexture chrominanceTexture:chrominanceTexture viewport:&viewport];
}

@end

