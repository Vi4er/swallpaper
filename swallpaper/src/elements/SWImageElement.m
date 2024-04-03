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

@end
