#import <elements/SWTextElement.h>
#import <scripting/SWElementParser.h>
#import <scripting/SWEnumParser.h>
#import <AppKit/AppKit.h>

@implementation SWTextLayer

- (CGSize)getTextSize {
    NSDictionary* attributes = @{NSFontAttributeName:(NSFont*)self.font};
    return [self.string sizeWithAttributes:attributes];
}

- (void)drawInContext:(CGContextRef)ctx {
    CGSize textSize = [self getTextSize];
    double offset = (self.bounds.size.height - textSize.height) / 2;

    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, offset);
    [super drawInContext:ctx];
    CGContextRestoreGState(ctx);
}

@end

@implementation SWTextElement

@dynamic layer;

-(CALayer*)createLayer {
    return [SWTextLayer layer];
}

-(void)sizeToFit {
    CGSize textSize = [self.layer getTextSize];
    SWRect frame = {0};
    frame.size.width.offset = textSize.width;
    frame.size.height.offset = textSize.height;
    self.frame = frame;
    [self updateFrame];
}

// TODO: Add Font
DECLARE_PROPERTIES(SWTextElement) {
    STRING_PROPERTY(text, self.layer.string);
    CGCOLOR_PROPERTY(foregroundColor, self.layer.foregroundColor);
    DEFINE_PROPERTY(fontSize, Number, ^NSNumber*(SWTextElement* self) {
        return [NSNumber numberWithDouble:self.layer.fontSize];
    }, ^void(SWTextElement* self, NSNumber* value) {
        self.layer.fontSize = value.doubleValue;
        self.layer.font = CFBridgingRetain([(NSFont*)self.layer.font fontWithSize:self.layer.fontSize]);
    });
    STRING_PROPERTY(horizontalTextAlignment, self.layer.alignmentMode);
}

@end
