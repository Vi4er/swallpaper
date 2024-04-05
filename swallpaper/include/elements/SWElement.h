#pragma once
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import <scripting/SWPropertyDefinition.h>
#import <elements/SWTypes.h>
#import <objc/runtime.h>

// Property Setup

#define DECLARE_PROPERTIES(_class) \
+ (SWPropertyDefinitions*)properties {\
    static SWPropertyDefinitions* properties;\
    if (!properties) {\
        properties = [[SWPropertyDefinitions alloc] init];\
        if ([[self superclass] respondsToSelector: @selector(properties)]) {\
            properties.parent = [[self superclass] properties];\
        }\
        [self setupProperties];\
    }\
return properties;\
}\
typedef _class* CLASS;\
+ (void)setupProperties

#define DEFINE_PROPERTY(name, _type, _getter, _setter) [[self properties] addPropertyDefinition:@#name type:kSWPropertyType##_type getter:_getter setter:_setter]

// Property Types

#define GENERIC_PROPERTY(name, path, type, swtype) DEFINE_PROPERTY(name, swtype, ^type(CLASS self) { return path; }, ^void(CLASS self, type value) { path = value; })
#define STRING_PROPERTY(name, path) GENERIC_PROPERTY(name, path, NSString*, String)
#define DOUBLE_PROPERTY(name, path) DEFINE_PROPERTY(name, Number, ^NSNumber*(CLASS self) { return [NSNumber numberWithDouble:path]; }, ^void(CLASS self, NSNumber* value) { path = value.doubleValue; })
#define BOOLEAN_PROPERTY(name, path) DEFINE_PROPERTY(name, Boolean, ^NSNumber*(CLASS self) { return [NSNumber numberWithBool:path]; }, ^void(CLASS self, NSNumber* value) { path = value.boolValue; })
#define CGCOLOR_PROPERTY(name, path) DEFINE_PROPERTY(name, Color, ^NSColor*(CLASS self) { return [NSColor colorWithCGColor:path];}, ^void(CLASS self, NSColor* color) { path = color.CGColor; })
#define POINT_PROPERTY(name, path) GENERIC_PROPERTY(name, path, SWPoint*, Point)
#define SIZE_PROPERTY(name, path) GENERIC_PROPERTY(name, path, SWSize*, Size)
#define VECTOR2_PROPERTY(name, path) GENERIC_PROPERTY(name, path, SWVector2*, Vector2)
#define ENUM_PROPERTY(name, path, selector) [[self properties] addEnumPropertyDefinition:@#name getter:^NSNumber*(CLASS self) { return [NSNumber numberWithInt:path];} setter:^void(CLASS self, NSNumber* value) { path = value.intValue; }  enumParserSelector:selector]

@interface SWElement : NSObject

@property SWElement* parent;
@property CALayer* layer;
@property SWRect* frame;
@property SWVector2* anchorPoint;
@property SWVector2* padding;
@property SWSizeConstraint sizeConstraint;
@property NSMutableArray* children;
@property bool draggable;

- (instancetype)initWithParent:(SWElement*)parent;
- (int)isRoot;
- (void)addChild:(SWElement*)child;
- (void)updateFrame;
- (CGRect)getRect;
- (CALayer*)createLayer;
- (void)setProperty:(NSString*)name value:(NSString*)value;

+ (instancetype)newWithParent:(SWElement*)parent;
+ (SWElement*)elementNamed:(NSString*)name;

+ (SWPropertyDefinitions*)properties;
+ (void)setupProperties;

@end
