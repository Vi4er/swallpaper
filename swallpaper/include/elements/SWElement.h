#pragma once
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import <scripting/SWPropertyDefinition.h>
#import <elements/SWTypes.h>
#import <objc/runtime.h>
#import <elements/SWEvent.h>

@interface SWElement : NSObject

@property NSString* elementId;
@property SWElement* parent;
@property CALayer* layer;
@property SWRect frame;
@property SWVector2 anchorPoint;
@property SWVector2 padding;
@property SWSizeConstraint sizeConstraint;
@property int zIndex;
@property bool draggable;
@property bool ignoresPointerEvents;
@property NSMutableArray* children;
@property (readonly) NSMutableDictionary<NSNumber*, NSMutableArray<NSNumber*>*>* eventListeners;

- (instancetype)initWithParent:(SWElement*)parent;
- (int)isRoot;
- (void)addChild:(SWElement*)child;
- (void)updateFrame;
- (CGRect)getRect;
- (CALayer*)createLayer;
- (void)setProperty:(NSString*)name value:(NSString*)value;
- (void)addEventListener:(SWEventType)event ref:(int)ref;
- (void)removeEventListener:(SWEventType)event ref:(int)ref;
- (void)triggerEvent:(SWEvent*)event;

+ (instancetype)newWithParent:(SWElement*)parent;
+ (SWElement*)elementNamed:(NSString*)name;

+ (NSMutableDictionary<NSString*, SWElement*>*)idMap;
+ (SWElement*)getElementById:(NSString*)elementId;

+ (SWPropertyDefinitions*)properties;
+ (void)setupProperties;

@end
