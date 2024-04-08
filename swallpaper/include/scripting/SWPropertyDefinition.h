#pragma once
#import <scripting/lua.h>
#import <Foundation/Foundation.h>

typedef id(*SWTypeParseXML)(id, SEL, NSString* str);
typedef id(^SWTypeParseXMLBlock)(NSString* str);
typedef int(*SWTypeParseEnum)(id, SEL, NSString* str);

typedef void(*SWTypeLuaPush)(lua_State* L, id value);
typedef id(*SWTypeLuaTo)(lua_State* L, int i);
typedef id(^SWPropertyGetterBlock)(id self);
typedef void(^SWPropertySetterBlock)(id self, id value);

typedef enum SWPropertyType {
    kSWPropertyTypeString,
    kSWPropertyTypeNumber,
    kSWPropertyTypeBoolean,
    kSWPropertyTypeColor,
    kSWPropertyTypePoint,
    kSWPropertyTypeSize,
    kSWPropertyTypeVector2,
    kSWPropertyTypeEnum,
    kSWPropertyTypeImage,
    kSWPropertyTypeCount
} SWPropertyType;

@interface SWPropertyTypeDefinition : NSObject

@property (nonatomic, copy) SWTypeParseXMLBlock parseFromXML;
@property SWTypeLuaPush luaPush;
@property SWTypeLuaTo luaTo;

- (instancetype)initWithParserSelector: (SEL)parserSelector luaPush:(SWTypeLuaPush)luaPush luaTo:(SWTypeLuaTo)luaTo;
+ (instancetype)newWithParserSelector: (SEL)parserSelector luaPush:(SWTypeLuaPush)luaPush luaTo:(SWTypeLuaTo)luaTo;

+ (NSArray<SWPropertyTypeDefinition*>*)typeDefinitions;
+ (int)parseEnum:(SEL)enumParseSelector value:(NSString*)value;

@end

@interface SWPropertyDefinition : NSObject

@property SWPropertyType type;
@property (nonatomic, copy) SWPropertyGetterBlock get;
@property (nonatomic, copy) SWPropertySetterBlock set;
@property SEL enumParseSelector;

- (instancetype)initWithType:(SWPropertyType)type getter:(SWPropertyGetterBlock)getter setter:(SWPropertySetterBlock)setter;


@end

@interface SWPropertyDefinitions : NSObject

@property SWPropertyDefinitions* parent;
@property (readonly) NSMutableDictionary<NSString*, SWPropertyDefinition*>* definitions;

- (instancetype)init: (SWPropertyDefinitions*)parent;

- (SWPropertyDefinition*)getPropertyDefinition: (NSString*)name;
- (void)addPropertyDefinition: (NSString*)name type:(SWPropertyType)type getter:(SWPropertyGetterBlock)getter setter:(SWPropertySetterBlock)setter;
- (void)addEnumPropertyDefinition: (NSString*)name getter:(SWPropertyGetterBlock)getter setter:(SWPropertySetterBlock)setter enumParserSelector:(SEL)enumParseSelector;

@end

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
