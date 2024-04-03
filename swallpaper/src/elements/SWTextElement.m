#import <elements/SWTextElement.h>
#import <AppKit/AppKit.h>

@implementation SWTextLayer

- (CGSize)getTextSize {
    NSDictionary* attributes = @{NSFontAttributeName: (NSFont*)self.font};
    return [self.string sizeWithAttributes:attributes];
}

- (void)drawInContext:(CGContextRef)ctx {
    // Center Y for now, change to support VerticalAlignment
    CGSize textSize = [self getTextSize];
    double offset = (self.bounds.size.height - textSize.height) / 2;

    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, -offset);
    [super drawInContext:ctx];
    CGContextRestoreGState(ctx);
}

@end

@implementation SWTextElement

@dynamic layer;

-(CALayer*)createLayer {
    return [CATextLayer layer];
}

-(void)sizeToFit {
    CGSize textSize = [self.layer getTextSize];

    SWRect frame = self.frame;
    frame.size.width.offset = textSize.width;
    frame.size.height.offset = textSize.height;
    self.frame = frame;
}

@end
