#import <SWGradientLayer.h>

@implementation SWGradientLayer

NSArray* effectColors;
NSArray* effectLocations;

- (NSArray*)colors {
    return effectColors == nil ? super.colors : effectColors;
}

- (NSArray<NSNumber*>*)locations {
    return effectLocations == nil ? super.locations : effectLocations;
}

- (void)waveEffect {
    [self removeAllAnimations];
    NSArray* colors = super.colors;

    for (int i = 0; i < 2; ++i) {
        for (id color in colors) {
            [(NSMutableArray*)effectColors addObject:color];
        }
    }
    
    int count = (int)colors.count;
    NSMutableArray* startLocations = [NSMutableArray arrayWithCapacity:count * 2];
    NSMutableArray* endLocations = [NSMutableArray arrayWithCapacity:count * 2];

    for (int i = -count; i < count; ++i) {
        [startLocations addObject: @(i / (count - 1.0))];
        [endLocations addObject: @((i + count) / (count - 1.0))];
    }

    effectLocations = startLocations;
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.fromValue = startLocations;
    animation.toValue = endLocations;
    animation.duration = 7.5;
    animation.repeatCount = HUGE_VALF;
    [self addAnimation:animation forKey:nil];
}

- (void)setEffect:(SWGradientEffect)effect {
    if (effect != kSWGradientEffectNone) {
        effectColors = [NSMutableArray array];
    }
    
    switch (effect) {
        case kSWGradientEffectNone: {
            effectColors = super.colors;
            effectLocations = super.locations;
            
            break;
        }
        case kSWGradientEffectWave: [self waveEffect]; break;
    }
}

@end
