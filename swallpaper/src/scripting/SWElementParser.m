#import <scripting/SWElementParser.h>
#import <SWColorUtils.h>

@implementation SWElementParser

+ (SWElement*)fromXMLElement:(NSXMLElement*)node {
    SWElement* element = [SWElement elementNamed:node.name];
    
    if (node.kind != NSXMLElementKind) {
        return nil;
    }
    
    if (element == nil) {
        NSLog(@"Invalid root element name '%@'\n", node.name);
        return nil;
    }
    
    for (NSXMLNode* attribute in node.attributes) {
        [element setProperty:attribute.name value:attribute.stringValue];
    }

    for (NSXMLElement* child in node.children) {
        SWElement* childElement = [SWElementParser fromXMLElement:child];
        
        if (childElement != nil) {
            childElement.parent = element;
        }
    }
        
    return element;
}

+ (SWElement*)parseFile:(NSString*)path {
    NSError* error = nil;
    NSData* xmlData = [NSData dataWithContentsOfFile:path];
    NSXMLDocument* document = [[NSXMLDocument alloc] initWithData:xmlData options:NSXMLNodeOptionsNone error:&error];
    
    if (error != nil) {
        NSLog(@"%@\n", error);
        return nil;
    }
    
    return [SWElementParser fromXMLElement:document.rootElement];
}

+ (NSString*)parseString:(NSString*)str {
    return str;
}

+ (NSColor*)parseColor:(NSString*)str {
    if ([str hasPrefix: @"rgb"]) {
        NSScanner* scanner = [NSScanner scannerWithString:str];
        [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"rgb(,) "]];

        double r, g, b, a = 255;
        if ([scanner scanDouble: &r] && [scanner scanDouble: &g] && [scanner scanDouble: &b]) {
            [scanner scanDouble: &a];
            return [NSColor colorWithCalibratedRed:r / 255 green:g / 255 blue:b / 255 alpha:a / 255];
        }
    }
    else if ([str hasPrefix:@"hsl"]) {
        NSScanner* scanner = [NSScanner scannerWithString:str];
        [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"hsl(,%) "]];

        double h, s, l, a = 255;
        if ([scanner scanDouble: &h] && [scanner scanDouble: &s] && [scanner scanDouble: &l]) {
            [scanner scanDouble: &a];

            s /= 100;
            l /= 100;

            double t = s * ((l < 0.5) ? l : (1.0 - l));
            double b = l + t;
            s = (l > 0.0) ? (2.0 * t / b) : 0.0;
            return [NSColor colorWithCalibratedHue:h saturation:s brightness:b alpha:a];
        }
    }
    else if ([str hasPrefix:@"#"]) {
        unsigned long long hexColor;
        NSScanner* scanner = [NSScanner scannerWithString:[str substringFromIndex:1]];

        if ([scanner scanHexLongLong:&hexColor]) {
            return SWColorDecode(hexColor);
        }
    }
    else {
        return [NSColor colorNamed:str];
    }
    
    return NSColor.blackColor;
}

+ (NSArray<NSNumber*>*)parseNumberList:(NSString*)str {
    NSMutableArray* array = [NSMutableArray array];
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped: [NSCharacterSet characterSetWithCharactersInString:@"{,} "]];
    double num;

    while ([scanner scanDouble:&num]) {
        [array addObject: [NSNumber numberWithDouble:num]];
    }
    
    return array;
}

+ (NSValue*)parseSWPoint:(NSString*)str {
    NSArray* numbers = [self parseNumberList:str];
    SWPoint point = {0};

    if (numbers.count == 4) {
        point.x.scale = [numbers[0] doubleValue];
        point.x.offset = [numbers[1] doubleValue];
        point.y.scale = [numbers[2] doubleValue];
        point.y.offset = [numbers[3] doubleValue];
    }

    return [NSValue valueWithSWPoint:point];
}

+ (NSValue*)parseSWSize:(NSString*)str {
    SWPoint point = [[self parseSWPoint:str] SWPointValue];
    SWSize size = {
        .width = point.x,
        .height = point.y
    };
    return [NSValue valueWithSWSize:size];
}

+ (NSValue*)parseSWVector2:(NSString*)str {
    NSArray* numbers = [self parseNumberList:str];
    SWVector2 vec2 = {0};

    if (numbers.count == 2) {
        vec2.x = [numbers[0] doubleValue];
        vec2.y = [numbers[1] doubleValue];
    }

    return [NSValue valueWithSWVector2:vec2];
}

+ (NSNumber*)parseNumber:(NSString*)str {
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [numberFormatter setNumberStyle:NSNumberFormatterScientificStyle];
    
    return [numberFormatter numberFromString:str];
}

+ (NSNumber*)parseBoolean:(NSString*)str {
    return [NSNumber numberWithBool:![[str lowercaseString] isEqualToString: @"false"]];
}

+ (NSImage*)parseImage:(NSString*)str {
    return [NSImage imageNamed:str];
}

@end
