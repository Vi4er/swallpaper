#pragma once
#import <Foundation/Foundation.h>

#define NSVALUE_INTERFACE(type) @interface NSValue (type)\
+ (instancetype)valueWith##type:(type)value;\
@property (readonly) type type##Value;\
@end

#define NSVALUE_IMPLEMENTATION(type) @implementation NSValue (type)\
+ (instancetype)valueWith##type:(type)value { return [self valueWithBytes:&value objCType:@encode(type)]; }\
- (type) type##Value { type value; [self getValue:&value]; return value; }\
@end

typedef struct SWScaled {
    double scale, offset;
} SWScaled;

NSVALUE_INTERFACE(SWScaled)

typedef struct SWScaled2 {
    SWScaled x, y;
} SWScaled2;

NSVALUE_INTERFACE(SWScaled2)

typedef struct SWRect {
    SWScaled2 origin, size;
} SWRect;

NSVALUE_INTERFACE(SWRect)

typedef struct SWVector2 {
    double x, y;
} SWVector2;

NSVALUE_INTERFACE(SWVector2)

typedef enum SWSizeConstraint {
    kSWSizeConstraintXY,
    kSWSizeConstraintXX,
    kSWSizeConstraintYY
} SWSizeConstraint;

static inline SWScaled SWMakeScaled(double scale, double offset) {
    SWScaled scaled = {
        .scale = scale,
        .offset = offset
    };
    
    return scaled;
}

static inline SWScaled2 SWMakeScaled2(SWScaled x, SWScaled y) {
    SWScaled2 scaled2 = {
        .x = x,
        .y = y
    };
    
    return scaled2;
}

static inline SWRect SWMakeRect(SWScaled x, SWScaled y, SWScaled width, SWScaled height) {
    SWRect rect = {
        .origin = SWMakeScaled2(x, y),
        .size = SWMakeScaled2(width, height)
    };
    
    return rect;
}
