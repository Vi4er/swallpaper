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

- (CALayer*)createLayer;
- (instancetype)initWithParent: (SWElement*)parent;
+ (instancetype)newWithParent: (SWElement*)parent;

- (CGRect)getRect;
- (int)setProperty:(NSString*)name value:(NSString*)value;

@end
