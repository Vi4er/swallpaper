#import <scripting/SWPropertyDefinition.h>
#import <scripting/SWElementParser.h>
#import <scripting/SWEnumParser.h>

@implementation SWPropertyTypeDefinition

- (instancetype)initWithParserSelector:(SEL)parserSelector luaPush:(SWTypeLuaPush)luaPush luaPop:(SWTypeLuaPop)luaPop {
    self = [super init];
    
    if (self) {
        SWTypeParseXML parseXML = (SWTypeParseXML)[SWElementParser methodForSelector:parserSelector];

        self.parseFromXML = ^id(NSString* value) {
            return parseXML([SWElementParser class], parserSelector, value);
        };
        self.luaPush = luaPush;
        self.luaPop = luaPop;
    }
    
    return self;
}

+ (id)newWithParserSelector:(SEL)parserSelector luaPush:(SWTypeLuaPush)luaPush luaPop:(SWTypeLuaPop)luaPop {
    return [[self alloc] initWithParserSelector:parserSelector luaPush:luaPush luaPop:luaPop];
}

+ (NSArray<SWPropertyTypeDefinition*>*)typeDefinitions {
    static NSMutableArray<SWPropertyTypeDefinition*>* typeDefinitions;
    
    if (typeDefinitions == nil) {
        typeDefinitions = [NSMutableArray arrayWithCapacity:kSWPropertyTypeCount];
        
        for (int i = 0; i < kSWPropertyTypeCount; ++i) {
            [typeDefinitions addObject:(SWPropertyTypeDefinition*)[NSNull null]];
        }
        
        typeDefinitions[kSWPropertyTypeString] = [SWPropertyTypeDefinition newWithParserSelector:@selector(parseString:) luaPush:0 luaPop:0];
        typeDefinitions[kSWPropertyTypeNumber] = [SWPropertyTypeDefinition newWithParserSelector:@selector(parseNumber:) luaPush:0 luaPop:0];
        typeDefinitions[kSWPropertyTypeBoolean] = [SWPropertyTypeDefinition newWithParserSelector:@selector(parseBoolean:) luaPush:0 luaPop:0];
        typeDefinitions[kSWPropertyTypeColor] = [SWPropertyTypeDefinition newWithParserSelector:@selector(parseColor:) luaPush:0 luaPop:0];
        typeDefinitions[kSWPropertyTypePoint] = [SWPropertyTypeDefinition newWithParserSelector:@selector(parseSWPoint:) luaPush:0 luaPop:0];
        typeDefinitions[kSWPropertyTypeSize] = [SWPropertyTypeDefinition newWithParserSelector:@selector(parseSWSize:) luaPush:0 luaPop:0];
        typeDefinitions[kSWPropertyTypeVector2] = [SWPropertyTypeDefinition newWithParserSelector:@selector(parseSWVector2:) luaPush:0 luaPop:0];
        typeDefinitions[kSWPropertyTypeImage] = [SWPropertyTypeDefinition newWithParserSelector:@selector(parseImage:) luaPush:0 luaPop:0];
    }
    
    return typeDefinitions;
}

+ (int)parseEnum:(SEL)enumParseSelector value:(NSString*)value {
    SWTypeParseEnum parseEnum = (SWTypeParseEnum)[SWEnumParser methodForSelector:enumParseSelector];
    return parseEnum([SWEnumParser class], enumParseSelector, value);
}

@end

@implementation SWPropertyDefinition

- (instancetype)initWithType:(SWPropertyType)type getter:(SWPropertyGetterBlock)getter setter:(SWPropertySetterBlock)setter {
    self = [super init];
    
    if (self) {
        self.type = type;
        self.get = getter;
        self.set = setter;
    }
    
    return self;
}

@end

@implementation SWPropertyDefinitions

- (instancetype)init
{
    self = [super init];

    if (self) {
        _definitions = [NSMutableDictionary dictionary];
    }

    return self;
}

- (instancetype)init:(SWPropertyDefinitions*)parent {
    self = [self init];

    if (self) {
        self.parent = parent;
    }

    return self;
}

- (SWPropertyDefinition*)getPropertyDefinition:(NSString*)name {
    id definition = self.definitions[name];
    
    if (!definition && self.parent) {
        return [self.parent getPropertyDefinition:name];
    }
    
    return definition;
}

- (void)addPropertyDefinition:(NSString *)name type:(SWPropertyType)type getter:(SWPropertyGetterBlock)getter setter:(SWPropertySetterBlock)setter {
    self.definitions[name] = [[SWPropertyDefinition alloc] initWithType:type getter:getter setter:setter];
}

- (void)addEnumPropertyDefinition:(NSString*)name getter:(SWPropertyGetterBlock)getter setter:(SWPropertySetterBlock)setter enumParserSelector:(SEL)enumParserSelector {
    SWPropertyDefinition* definition = [[SWPropertyDefinition alloc] initWithType:kSWPropertyTypeEnum getter:getter setter:setter];
    definition.enumParseSelector = enumParserSelector;
    self.definitions[name] = definition;
}

@end
