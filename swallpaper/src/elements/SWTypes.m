#import <elements/SWTypes.h>

@implementation SWScaled

- (instancetype)initWithScale:(double)scale offset:(double)offset {
    self = [self init];
    
    if (self) {
        self.scale = scale;
        self.offset = offset;
    }
    
    return self;
}

+ (instancetype)newWithScale:(double)scale offset:(double)offset {
    return [[self alloc] initWithScale:scale offset:offset];
}

@end

@implementation SWPoint

- (instancetype)initWithX:(SWScaled*)x y:(SWScaled*)y {
    self = [self init];
    
    if (self) {
        self.x = x;
        self.y = y;
    }
    
    return self;
}

+ (instancetype)newWithX:(SWScaled*)x y:(SWScaled*)y {
    return [[self alloc] initWithX:x y:y];
}

@end

@implementation SWSize

- (instancetype)initWithWidth:(SWScaled*)width height:(SWScaled*)height {
    self = [self init];
    
    if (self) {
        self.width = width;
        self.height = height;
    }
    
    return self;
}

+ (instancetype)newWithWidth:(SWScaled*)width height:(SWScaled*)height {
    return [[self alloc] initWithWidth:width height:height];
}


@end

@implementation SWRect

- (instancetype)initWithOrigin:(SWPoint*)origin size:(SWSize*)size {
    self = [self init];
    
    if (self) {
        self.origin = origin;
        self.size = size;
    }
    
    return self;
}

+ (instancetype)newWithOrigin:(SWPoint*)origin size:(SWSize*)size {
    return [[self alloc] initWithOrigin:origin size:size];
}

@end

@implementation SWVector2

- (instancetype)initWithX:(double)x y:(double)y {
    self = [self init];
    
    if (self) {
        self.x = x;
        self.y = y;
    }
    
    return self;
}

+ (instancetype)newWithX:(double)x y:(double)y {
    return [[self alloc] initWithX:x y:y];
}

@end
