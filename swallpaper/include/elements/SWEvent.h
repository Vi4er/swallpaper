#pragma once
#import <Foundation/Foundation.h>

typedef enum SWEventType {
    kSWEventTypeInvalid,
    kSWEventTypeMouseEnter,
    kSWEventTypeMouseLeave
} SWEventType;

@interface SWEvent : NSObject

@property SWEventType type;

@end

@interface SWMouseEvent : SWEvent

@property NSPoint origin;

@end
