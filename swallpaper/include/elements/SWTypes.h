#pragma once
#import <Foundation/Foundation.h>

@interface SWScaled : NSObject

@property double scale, offset;

- (instancetype)initWithScale: (double)scale offset:(double)offset;
+ (instancetype)newWithScale: (double)scale offset:(double)offset;

@end

@interface SWPoint : NSObject

@property SWScaled* x;
@property SWScaled* y;

- (instancetype)initWithX: (SWScaled*)x y:(SWScaled*)y;
+ (instancetype)newWithX: (SWScaled*)x y:(SWScaled*)y;

@end

@interface SWSize : NSObject

@property SWScaled* width;
@property SWScaled* height;

- (instancetype)initWithWidth: (SWScaled*)width height:(SWScaled*)height;
+ (instancetype)newWithWidth: (SWScaled*)width height:(SWScaled*)height;

@end

@interface SWRect : NSObject

@property SWPoint* origin;
@property SWSize* size;

- (instancetype)initWithOrigin: (SWPoint*)origin size:(SWSize*)size;
+ (instancetype)newWithOrigin: (SWPoint*)origin size:(SWSize*)size;

@end

@interface SWVector2 : NSObject

@property double x, y;

- (instancetype)initWithX: (double)x y:(double)y;
+ (instancetype)newWithX: (double)x y:(double)y;

@end

typedef enum SWSizeConstraint {
    kSWSizeConstraintXY,
    kSWSizeConstraintXX,
    kSWSizeConstraintYY
} SWSizeConstraint;
