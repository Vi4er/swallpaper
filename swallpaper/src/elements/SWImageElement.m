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

DECLARE_PROPERTIES(SWImageElement) {
    DEFINE_PROPERTY(image, Image, ^NSImage*(SWImageElement* self) {
        return self.image;
    }, ^void(SWImageElement* self, NSImage* image) {
        self.image = image;
    });
}

@end
