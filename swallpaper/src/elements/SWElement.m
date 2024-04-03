#import <elements/SWElement.h>
#import <SWWallpaper.h>
#import <elements/SWElementParser.h>

// TODO: This is a general implementation and needs to be cleaned and have a nice way to add subelement, also clean SWTextElement and make proper way to scale a child layer such as the CATextLayer when setting the frame

@implementation SWElement

@synthesize frame = _frame;

- (CALayer*)createLayer {
    return [CALayer layer];
}

- (instancetype)initWithParent:(SWElement*)parent {
    self = [super init];
    
    if (self) {
        self.parent = parent;
        self.layer = [self createLayer];

        if ([parent isKindOfClass:[SWWallpaper class]]) {
            [((SWWallpaper*)parent).window.contentView.layer addSublayer:self.layer];
        }
        else if (parent) {
            [parent.layer addSublayer:self.layer];
        }
    }
    
    return self;
}

+ (instancetype)newWithParent:(SWElement*)parent {
    return [[self alloc] initWithParent:parent];
}

- (SWRect)frame {
    return _frame;
}

- (void)setFrame:(SWRect)frame {
    _frame = frame;
    self.layer.frame = [self getRect];
}

- (void)updateFrame {
    self.layer.frame = [self getRect];
}

double scaledValue(double parentValue, SWScaled value) {
    return parentValue * value.scale + value.offset;
}

- (CGRect)getRect {
    if ([self isKindOfClass:[SWWallpaper class]]) {
        return ((SWWallpaper*)self).screen.frame;
    }
    
    // Cannot scale without a parent
    if (!self.parent) {
        return CGRectMake(0, 0, 0, 0);
    }
    
    CGRect parentRect = [self.parent getRect];
    float x = scaledValue(parentRect.size.width, self.frame.position.x);
    float y = scaledValue(parentRect.size.height, self.frame.position.y);
    float width = scaledValue(parentRect.size.width, self.frame.size.width);
    float height = scaledValue(parentRect.size.height, self.frame.size.height);
    
    width += self.padding.width * 2;
    height += self.padding.height * 2;
    
    if (self.sizeConstraint == kSWSizeConstraintXX) {
        height = width;
    }
    else if (self.sizeConstraint == kSWSizeConstraintYY) {
        width = height;
    }
    
    x -= width * self.anchorPoint.x;
    y -= height * self.anchorPoint.y;

    return CGRectMake(x, y, width, height);
}

- (int)setProperty:(NSString*)name value:(NSString*)value {
    if ([name isEqualToString:@"backgroundColor"]) {
        self.layer.backgroundColor = [SWElementParser parseColor:value].CGColor;
        return 1;
    }
    else if ([name isEqualToString:@"position"]) {
        SWRect frame = self.frame;
        frame.position = [SWElementParser parseSWPosition:value];
        self.frame = frame;
        return 1;
    }
    else if ([name isEqualToString:@"size"]) {
        SWRect frame = self.frame;
        frame.size = [SWElementParser parseSWSize:value];
        self.frame = frame;
        return 1;
    }
    else if ([name isEqualToString:@"anchorPoint"]) {
        self.anchorPoint = [SWElementParser parseCGPoint:value];
        [self updateFrame];
        return 1;
    }
    else if ([name isEqualToString:@"cornerRadius"]) {
        NSNumber* num = [SWElementParser parseNumber:value];

        if (num != nil) {
            self.layer.cornerRadius = num.doubleValue;
        }
    }
    else if ([name isEqualToString:@"maskToBounds"]) {
        self.layer.masksToBounds = [SWElementParser parseBoolean:value];
    }
    else if ([name isEqualToString:@"sizeConstraint"]) {
        self.sizeConstraint = [SWElementParser parseSWSizeConstraint:value];
        [self updateFrame];
    }
 
    return 0;
}

@end
