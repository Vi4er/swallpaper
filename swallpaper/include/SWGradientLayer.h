#pragma once
#import <QuartzCore/QuartzCore.h>

typedef enum {
    kSWGradientEffectNone,
    kSWGradientEffectWave
} SWGradientEffect;

@interface SWGradientLayer : CAGradientLayer

- (void)setEffect:(SWGradientEffect)effect;

@end
