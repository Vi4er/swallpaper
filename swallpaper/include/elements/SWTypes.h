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

typedef struct SWPoint {
    SWScaled x;
    SWScaled y;
} SWPoint;

NSVALUE_INTERFACE(SWPoint)

typedef struct SWSize {
    SWScaled width;
    SWScaled height;
} SWSize;

NSVALUE_INTERFACE(SWSize)

typedef struct SWRect {
    SWPoint origin;
    SWSize size;
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
