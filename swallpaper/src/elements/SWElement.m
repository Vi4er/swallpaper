#import <elements/SWElement.h>
#import <SWWallpaper.h>
#import <elements/SWElementParser.h>
#import <elements/SWTextElement.h>
#import <elements/SWImageElement.h>

@implementation SWElement

@synthesize frame = _frame;
@synthesize parent = _parent;

-(instancetype)init {
    self = [super init];
    
    if (self) {
        if (![self isRoot]) {
            self.layer = [self createLayer];
        }
        
        self.children = [NSMutableArray array];
    }
    
    return self;
}

- (instancetype)initWithParent:(SWElement*)parent {
    self = [self init];
    
    if (self) {
        [parent addChild:self];
    }
    
    return self;
}

- (int)isRoot {
    return [self isKindOfClass:[SWWallpaper class]];
}

- (void)addChild:(SWElement*)child {
    child.parent = self;
}

- (SWElement*)parent {
    return _parent;
}

- (void)setParent:(SWElement*)parent {
    _parent = parent;
    [self.layer removeFromSuperlayer];

    if (parent) {
        if ([parent isRoot]) {
            [((SWWallpaper*)parent).window.contentView.layer addSublayer:self.layer];
        }
        else {
            [parent.layer addSublayer:self.layer];
        }

        [parent.children addObject:self];
    }
    
    [self updateFrame];
}

- (SWRect)frame {
    return _frame;
}

- (void)setFrame:(SWRect)frame {
    _frame = frame;
    [self updateFrame];
}

- (void)updateFrame {
    self.layer.frame = [self getRect];
    
    for (SWElement* child in self.children) {
        [child updateFrame];
    }
}

double scaledValue(double parentValue, SWScaled value) {
    return parentValue * value.scale + value.offset;
}

- (CGRect)getRect {
    if ([self isRoot]) {
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

- (CALayer*)createLayer {
    return [CALayer layer];
}

- (int)setProperty:(NSString*)name value:(NSString*)value {
    if ([name isEqualToString:@"backgroundColor"]) {
        self.layer.backgroundColor = [SWElementParser parseColor:value].CGColor;
    }
    else if ([name isEqualToString:@"position"]) {
        SWRect frame = self.frame;
        frame.position = [SWElementParser parseSWPosition:value];
        self.frame = frame;
    }
    else if ([name isEqualToString:@"size"]) {
        SWRect frame = self.frame;
        frame.size = [SWElementParser parseSWSize:value];
        self.frame = frame;
    }
    else if ([name isEqualToString:@"padding"]) {
        self.padding = [SWElementParser parseCGSize:value];
        [self updateFrame];
    }
    else if ([name isEqualToString:@"anchorPoint"]) {
        self.anchorPoint = [SWElementParser parseCGPoint:value];
        [self updateFrame];
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
    else {
        return 0;
    }
 
    return 1;
}

+ (instancetype)newWithParent:(SWElement*)parent {
    return [[self alloc] initWithParent:parent];
}

+ (SWElement*)elementNamed:(NSString*)name {
    if ([name isEqualToString:@"SW"]) {
        return [SWElement new];
    }
    else if ([name isEqualToString:@"SWText"]) {
        return [SWTextElement new];
    }
    else if ([name isEqualToString:@"SWImage"]) {
        return [SWImageElement new];
    }
    else {
        return nil;
    }
}

@end
