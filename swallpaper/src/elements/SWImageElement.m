#import <elements/SWImageElement.h>

@implementation SWImageElement

@synthesize image = _image;

-(NSImage*)image {
    return _image;
}

-(void)setImage:(NSImage*)image {
    _image = image;
    self.layer.contents = image;
}

-(int)setProperty:(NSString*)name value:(NSString*)value {
    if ([name isEqualToString:@"image"]) {
        self.image = [NSImage imageNamed:value];
    }
    else {
        return [super setProperty:name value:value];
    }

    return 1;
}

@end
