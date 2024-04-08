#pragma once
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import <scripting/SWPropertyDefinition.h>
#import <elements/SWTypes.h>
#import <objc/runtime.h>

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
