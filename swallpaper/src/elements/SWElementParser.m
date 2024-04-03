#import <elements/SWElementParser.h>
#import <SWColorUtils.h>

@implementation SWElementParser

+ (SWElement*)fromXMLElement:(NSXMLElement*)node {
    SWElement* element = [SWElement elementNamed:node.name];
    
    if (element == nil) {
        NSLog(@"Invalid root element name '%@'\n", node.name);
        return nil;
    }
    
    for (NSXMLNode* attribute in node.attributes) {
        [element setProperty:attribute.name value:attribute.stringValue];
    }

    for (NSXMLElement* child in node.children) {
        SWElement* childElement = [SWElementParser fromXMLElement:child];
        childElement.parent = element;
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

+ (SWPosition)parseSWPosition:(NSString*)str {
    NSArray* numbers = [self parseNumberList:str];
    
    if (numbers.count == 4) {
        return SWPositionMake(
                    SWScaledMake([numbers[0] doubleValue], [numbers[1] doubleValue]),
                    SWScaledMake([numbers[2] doubleValue], [numbers[3] doubleValue])
                );
    }

    SWPosition position = {0};
    return position;
}

+ (SWSize)parseSWSize:(NSString*)str {
    SWPosition pos = [self parseSWPosition:str];
    return SWSizeMake(pos.x, pos.y);
}

+ (CGPoint)parseCGPoint:(NSString*)str {
    NSArray* numbers = [self parseNumberList:str];

    if (numbers.count == 2) {
        return CGPointMake([numbers[0] doubleValue], [numbers[1] doubleValue]);
    }

    return CGPointMake(0, 0);
}

+ (CGSize)parseCGSize:(NSString*)str {
    CGPoint point = [self parseCGPoint:str];
    return CGSizeMake(point.x, point.y);
}

+ (NSNumber*)parseNumber:(NSString*)str {
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [numberFormatter setNumberStyle:NSNumberFormatterScientificStyle];
    
    return [numberFormatter numberFromString:str];
}

+ (int)parseBoolean:(NSString*)str {
    return ![[str lowercaseString] isEqualToString: @"false"];
}

+ (SWSizeConstraint)parseSWSizeConstraint:(NSString*)str {
    str = [str lowercaseString];
    
    if ([str isEqualToString:@"xx"]) {
        return kSWSizeConstraintXX;
    }
    else if ([str isEqualToString:@"yy"]) {
        return kSWSizeConstraintYY;
    }
    else {
        return kSWSizeConstraintXY;
    }
}

@end
