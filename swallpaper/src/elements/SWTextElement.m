#import <elements/SWTextElement.h>
#import <scripting/SWElementParser.h>
#import <scripting/SWEnumParser.h>
#import <AppKit/AppKit.h>

@implementation SWTextLayer

@synthesize string = _string;

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
    SWTextLayer* layer = [SWTextLayer layer];
    // TODO: Improve this
    layer.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
//    layer.font = (__bridge CFTypeRef _Nullable)([NSFont fontWithName:@"SF-Pro-Rounded-Semibold" size:14.0]);
    
    return layer;
}

-(void)sizeToFit {
    CGSize textSize = [self.layer getTextSize];
    SWRect frame = self.frame;
    frame.size.x.scale = frame.size.y.scale = 0;
    frame.size.x.offset = textSize.width;
    frame.size.y.offset = textSize.height;
    self.frame = frame;
}

// TODO: Add Font
DECLARE_PROPERTIES(SWTextElement) {
    DEFINE_PROPERTY(text, String, ^NSString*(SWTextElement* self) {
        return self.layer.string;
    }, ^void(SWTextElement* self, NSString* str) {
        self.layer.string = str;
        if (self.sizesToFit) {
            [self sizeToFit];
        }
    });
    CGCOLOR_PROPERTY(foregroundColor, self.layer.foregroundColor);
    DEFINE_PROPERTY(fontSize, Number, ^NSNumber*(SWTextElement* self) {
        return [NSNumber numberWithDouble:self.layer.fontSize];
    }, ^void(SWTextElement* self, NSNumber* value) {
        self.layer.fontSize = value.doubleValue;
//        self.layer.font = CFBridgingRetain([(NSFont*)self.layer.font fontWithSize:self.layer.fontSize]);
        
        NSFont* systemFont = [NSFont systemFontOfSize:self.layer.fontSize weight:NSFontWeightSemibold];
        self.layer.font = CFBridgingRetain([NSFont fontWithDescriptor: [systemFont.fontDescriptor fontDescriptorWithDesign:NSFontDescriptorSystemDesignRounded]
 size:self.layer.fontSize]);
    });
    DEFINE_PROPERTY(sizesToFit, Boolean, ^NSNumber*(SWTextElement* self) {
        return [NSNumber numberWithInt:self.sizesToFit];
    }, ^void(SWTextElement* self, NSNumber* value) {
        self.sizesToFit = value.intValue;

        if (value.intValue) {
            [self sizeToFit];
        }
    });
    STRING_PROPERTY(horizontalTextAlignment, self.layer.alignmentMode);
}

@end
