#pragma once
#import <QuartzCore/QuartzCore.h>
#import <elements/SWTypes.h>

@interface SWElement : NSObject

@property SWElement* parent;
@property CALayer* layer;
@property SWRect frame;
@property CGPoint anchorPoint;
@property CGSize padding;
@property SWSizeConstraint sizeConstraint;
@property NSMutableArray* children;

- (instancetype)initWithParent:(SWElement*)parent;
- (int)isRoot;
- (void)addChild:(SWElement*)child;
- (void)updateFrame;
- (CGRect)getRect;
- (CALayer*)createLayer;
- (int)setProperty:(NSString*)name value:(NSString*)value;

+ (instancetype)newWithParent:(SWElement*)parent;
+ (SWElement*)elementNamed:(NSString*)name;

@end
