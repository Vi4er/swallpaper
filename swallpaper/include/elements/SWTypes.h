#pragma once

typedef struct SWScaled {
    double scale, offset;
} SWScaled;

typedef struct SWPosition {
    SWScaled x, y;
} SWPosition;

typedef struct SWSize {
    SWScaled width, height;
} SWSize;

typedef struct SWRect {
    SWPosition position;
    SWSize size;
} SWRect;

typedef enum SWSizeConstraint {
    kSWSizeConstraintXY,
    kSWSizeConstraintXX,
    kSWSizeConstraintYY
} SWSizeConstraint;

static inline SWScaled SWScaledMake(double scale, double offset) {
    SWScaled scaled = {
        .scale = scale,
        .offset = offset
    };
    
    return scaled;
}

static inline SWPosition SWPositionMake(SWScaled x, SWScaled y) {
    SWPosition position = {
        .x = x,
        .y = y
    };
    
    return position;
}

static inline SWSize SWSizeMake(SWScaled width, SWScaled height) {
    SWSize size = {
        .width = width,
        .height = height
    };
    
    return size;
}

static inline SWRect SWRectMake(SWScaled x, SWScaled y, SWScaled width, SWScaled height) {
    SWRect rect = {
        .position = SWPositionMake(x, y),
        .size = SWSizeMake(width, height)
    };
    
    return rect;
}
