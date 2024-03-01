#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

vertex VertexOut hwvideoVertex(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = float4(in.position.xy, 0, 1);
    out.texCoord = in.texCoord;

    return out;
}

fragment float4 hwvideoFragment(VertexOut fragmentIn [[stage_in]],
                               texture2d<float> luminanceTexture [[texture(0)]],
                               texture2d<float> chrominanceTexture [[texture(1)]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);

    float y = luminanceTexture.sample(s, fragmentIn.texCoord).r;
    float2 chroma = chrominanceTexture.sample(s, fragmentIn.texCoord).rg - float2(0.5);

    float r = y + 1.402 * chroma.y;
    float g = y - 0.344136 * chroma.x - 0.714136 * chroma.y;
    float b = y + 1.772 * chroma.x;

    return float4(r, g, b, 1.0);
}
