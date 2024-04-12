#import <scripting/SWEnumParser.h>

@implementation SWEnumParser

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

+ (SWEventType)parseSWEvent:(NSString*)str {
    if ([str isEqualToString:@"onMouseEnter"]) {
        return kSWEventTypeMouseEnter;
    }
    else if ([str isEqualTo:@"onMouseLeave"]) {
        return kSWEventTypeMouseLeave;
    }
    else {
        return kSWEventTypeInvalid;
    }
}

@end
