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
    DEFINE_PROPERTY(image, String, ^NSString*(SWImageElement* self) {
        return [self.image name];
    }, ^void(SWImageElement* self, NSString* image) {
        self.image = [NSImage imageNamed:image];
    });
}

@end
