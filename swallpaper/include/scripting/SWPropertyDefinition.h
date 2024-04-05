#pragma once
#import <Foundation/Foundation.h>

typedef id(*SWTypeParseXML)(id, SEL, NSString* str);
typedef int(*SWTypeParseEnum)(id, SEL, NSString* str);
typedef id(^SWTypeParseXMLBlock)(NSString* str);
typedef void(*SWTypeLuaPush)(void* luaState); // TEMPORARY, pushes value to lua stack
typedef void*(*SWTypeLuaPop)(void* luaState); // TEMPORARY, pops value off of lua stack
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
@property SWTypeLuaPop luaPop;

- (instancetype)initWithParserSelector: (SEL)parserSelector luaPush:(SWTypeLuaPush)luaPush luaPop:(SWTypeLuaPop)luaPop;
+ (instancetype)newWithParserSelector: (SEL)parserSelector luaPush:(SWTypeLuaPush)luaPush luaPop:(SWTypeLuaPop)luaPop;

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
