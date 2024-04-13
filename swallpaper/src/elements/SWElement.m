#import <elements/SWElement.h>
#import <elements/SWTextElement.h>
#import <elements/SWImageElement.h>
#import <scripting/SWEnumParser.h>
#import <scripting/types/SWEvent.h>
#import <SWWallpaper.h>
#import <scripting/lua.h>

@implementation SWElement

@synthesize elementId = _elementId;
@synthesize layer = _layer;
@synthesize parent = _parent;
@synthesize eventListeners = _eventListeners;

typedef void*(*isRoot)(void* element);

-(instancetype)init {
    self = [super init];
    
    if (self) {
        if (![self isRoot]) {
            self.layer = [self createLayer];
            SWRect frame = {0};
            self.frame = frame;
            _eventListeners = [NSMutableDictionary dictionary];
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

- (CALayer*)layer {
    if ([self isRoot]) {
        return ((SWWallpaper*)self).window.contentView.layer;
    }
    else {
        return _layer;
    }
}

- (void)setLayer:(CALayer*)layer {
    if ([self isRoot]) {
        ((SWWallpaper*)self).window.contentView.layer = layer;
    }
    else {
        _layer = layer;
    }
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
        [parent.layer addSublayer:self.layer];
        [parent.children addObject:self];
    }
    
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
        return ((SWWallpaper*)self).window.screen.frame;
    }
    
    // Cannot scale without a parent
    if (!self.parent) {
        return CGRectMake(0, 0, 0, 0);
    }
    
    CGRect parentRect = [self.parent getRect];
    float x = scaledValue(parentRect.size.width, self.frame.origin.x);
    float y = scaledValue(parentRect.size.height, self.frame.origin.y);
    float width = scaledValue(parentRect.size.width, self.frame.size.width);
    float height = scaledValue(parentRect.size.height, self.frame.size.height);
    
    width += self.padding.x * 2;
    height += self.padding.y * 2;
    
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

- (void)setProperty:(NSString*)name value:(NSString*)value {
    SWPropertyDefinition* definition = [[[self class] properties] getPropertyDefinition:name];
    
    if (definition.type == kSWPropertyTypeEnum) {
        definition.set(self, [NSNumber numberWithInt:[SWPropertyTypeDefinition parseEnum:definition.enumParseSelector value:value]]);
        return;
    }
    
    if (!definition) {
        NSLog(@"Invalid property name for '%@' ('%@')\n", [self className], name);
        return;
    }
    
    definition.set(self, [SWPropertyTypeDefinition typeDefinitions][definition.type].parseFromXML(value));
}

- (void)addEventListener:(SWEventType)event ref:(int)ref {
    if (!event) {
        return;
    }
    
    NSNumber* key = [NSNumber numberWithInt:event];

    if (![self.eventListeners objectForKey:key]) {
        self.eventListeners[key] = [NSMutableArray array];
    }
    
    [self.eventListeners[key] addObject:[NSNumber numberWithInt:ref]];
}

- (void)removeEventListener:(SWEventType)event ref:(int)ref {
    if (!event) {
        return;
    }
    
    NSNumber* key = [NSNumber numberWithInt:event];
    [self.eventListeners[key] removeObject:[NSNumber numberWithInt:ref]];
    
    luaL_unref(SWLuaState, LUA_REGISTRYINDEX, ref);
}

- (void)triggerEvent:(SWEvent*)event {
    NSNumber* key = [NSNumber numberWithInt:event.type];

    if (![self.eventListeners objectForKey:key]) {
        return;
    }
    
    for (NSNumber* ref in [self.eventListeners objectForKey:key]) {
        lua_rawgeti(SWLuaState, LUA_REGISTRYINDEX, [ref intValue]);
        lua_pushSWEvent(SWLuaState, event);
        lua_call(SWLuaState, 1, 0);
    }
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

+ (NSMutableDictionary<NSString*,SWElement*>*)idMap {
    static NSMutableDictionary* idMap;
    
    if (idMap == nil) {
        idMap = [NSMutableDictionary dictionary];
    }
    
    return idMap;
}

+ (SWElement*)getElementById:(NSString*)elementId {
    return [[self class] idMap][elementId];
}

- (NSString*)elementId {
    return _elementId;
}

- (void)setElementId:(NSString*)elementId {
    _elementId = elementId;
    [[self class] idMap][elementId] = self;
}

DECLARE_PROPERTIES(SWElement) {
    STRING_PROPERTY(id, self.elementId);
    DEFINE_PROPERTY(origin, Point,
        ^NSValue*(SWElement* self) {
            return [NSValue valueWithSWPoint:self.frame.origin];
        },
        ^void(SWElement* self, NSValue* value) {
            SWRect frame = self.frame;
            frame.origin = [value SWPointValue];
            self.frame = frame;
            [self updateFrame];
        }
    );
    DEFINE_PROPERTY(size, Size,
        ^NSValue*(SWElement* self) {
            return [NSValue valueWithSWSize:self.frame.size];
        },
        ^void(SWElement* self, NSValue* value) {
            SWRect frame = self.frame;
            frame.size = [value SWSizeValue];
            self.frame = frame;
            [self updateFrame];
        }
    );
    VECTOR2_PROPERTY(padding, self.padding);
    VECTOR2_PROPERTY(anchorPoint, self.anchorPoint);
    BOOLEAN_PROPERTY(masksToBounds, self.layer.masksToBounds);
    DOUBLE_PROPERTY(cornerRadius, self.layer.cornerRadius);
    CGCOLOR_PROPERTY(backgroundColor, self.layer.backgroundColor);
    BOOLEAN_PROPERTY(draggable, self.draggable);
    DOUBLE_PROPERTY(zIndex, self.zIndex);
    BOOLEAN_PROPERTY(ignoresPointerEvents, self.ignoresPointerEvents);
    ENUM_PROPERTY(sizeConstraint, self.sizeConstraint, @selector(parseSWSizeConstraint:));
}

@end
