#import <SWGradientLayer.h>

@implementation SWGradientLayer

NSArray* effectColors;
NSArray* effectLocations;

- (id)init {
    self = [super init];
    
    if (self) {
        effectColors = [NSMutableArray array];
    }
    
    return self;
}

- (NSArray*)colors {
    return effectColors;
}

- (NSArray<NSNumber*>*)locations {
    return effectLocations;
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
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"locations"];

    NSMutableArray* startLocations = [NSMutableArray arrayWithCapacity:count * 2];
    for (int i = -count; i < count; ++i) {
        [startLocations addObject: @(i / (count - 1.0))];
    }
    
    NSMutableArray* endLocations = [NSMutableArray arrayWithCapacity:count * 2];
    for (int i = 0; i < count * 2; ++i) {
        [endLocations addObject: @(i / (count - 1.0))];
    }
    
    effectLocations = startLocations;
    animation.fromValue = startLocations;
    animation.toValue = endLocations;
    animation.duration = 7.5;
    animation.repeatCount = HUGE_VALF;
    [self addAnimation:animation forKey:nil];
}

- (void)setEffect: (SWGradientEffect)effect {
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
