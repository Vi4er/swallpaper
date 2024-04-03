#import <elements/SWTextElement.h>
#import <elements/SWElementParser.h>
#import <AppKit/AppKit.h>

@implementation SWTextLayer

- (CGSize)getTextSize {
    NSDictionary* attributes = @{NSFontAttributeName:(NSFont*)self.font};
    return [self.string sizeWithAttributes:attributes];
}

- (void)drawInContext:(CGContextRef)ctx {
//     Center Y for now, change to support VerticalAlignment
//    CGSize textSize = [self getTextSize];
//    double offset = (self.bounds.size.height - textSize.height) / 2;
//
//    CGContextSaveGState(ctx);
//    CGContextTranslateCTM(ctx, 0, -offset);
    [super drawInContext:ctx];
//    CGContextRestoreGState(ctx);
}

@end

@implementation SWTextElement

@dynamic layer;

-(CALayer*)createLayer {
    return [SWTextLayer layer];
}

-(void)sizeToFit {
    CGSize textSize = [self.layer getTextSize];

    SWRect frame = self.frame;
    frame.size.width.scale = frame.size.height.scale = 0;
    frame.size.width.offset = textSize.width;
    frame.size.height.offset = textSize.height;
    self.frame = frame;
}

- (int)setProperty:(NSString*)name value:(NSString*)value {
    if ([name isEqualToString:@"text"]) {
        self.layer.string = value;
    }
    else if ([name isEqualToString:@"foregroundColor"]) {
        self.layer.foregroundColor = [SWElementParser parseColor:value].CGColor;
    }
    else if ([name isEqualToString:@"fontSize"]) {
        self.layer.fontSize = [SWElementParser parseNumber:value].doubleValue;
    }
    else if ([name isEqualToString:@"font"]) {
        self.layer.font = CFBridgingRetain([NSFont boldSystemFontOfSize: self.layer.fontSize]);
    }
    else if ([name isEqualToString:@"horizontalTextAlignment"]) {
        value = [value lowercaseString];

        if ([value isEqualToString:@"center"]) {
            self.layer.alignmentMode = kCAAlignmentCenter;
        }
        else if ([value isEqualToString:@"left"]) {
            self.layer.alignmentMode = kCAAlignmentLeft;
        }
        else if ([value isEqualToString:@"right"]) {
            self.layer.alignmentMode = kCAAlignmentRight;
        }
        else {
            self.layer.alignmentMode = kCAAlignmentNatural;
        }
    }
    else {
        return [super setProperty:name value:value];
    }
    
    return 1;
}

@end
