#import <SWScene.h>
#import <SWColorUtils.h>
#import <objc/runtime.h>

@implementation NSData (SWDataReader)

#define READ_TYPE(type) type result; \
int size = sizeof(result); \
if (self.location + size > self.length) { return 0; } \
[self getBytes:&result range:NSMakeRange(self.location, size)]; \
self.location += size; \
return result;

- (void)skip:(int)amount {
    if (self.location + amount > self.length) {
        return;
    }
    
    self.location += amount;
}

- (NSUInteger)readNextBytes:(unsigned char*)buffer length:(NSUInteger)length {
    NSUInteger readLength = MIN(length, self.length - self.location);
    
    if (readLength > 0) {
        [self getBytes:buffer range:NSMakeRange(self.location, readLength)];
        self.location += readLength;
    }
    
    return readLength;
}

- (NSString*)readNextString {
    if (self.location >= self.length) {
        return nil;
    }

    const char* bytes = self.bytes + self.location;
    size_t strLength = strlen(bytes);
    
    if (strLength < self.length - self.location) {
        NSString* string = [[NSString alloc] initWithBytes:bytes length:strLength encoding:NSUTF8StringEncoding];
        self.location += strLength + 1;
        
        return string;
    }
    
    return nil;
}

- (int)readNextInt {
    READ_TYPE(int);
}

- (unsigned int)readNextUInt {
    READ_TYPE(unsigned int);
}

- (float)readNextFloat {
    READ_TYPE(float);
}

- (NSColor*)readNextColor {
    return SWColorDecode([self readNextUInt]);
}

- (unsigned long)location {
    return ((NSNumber*)objc_getAssociatedObject(self, @selector(location))).unsignedLongValue;
}

- (void)setLocation:(unsigned long)location {
    objc_setAssociatedObject(self, @selector(location), [NSNumber numberWithUnsignedLong: location], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation NSMutableData (SWDataWriter)

- (void)writeBytes:(unsigned char*)buffer length:(NSUInteger)length {
    [self appendBytes:buffer length:length];
}

- (void)writeString:(NSString*)string {
    [self appendData: [string dataUsingEncoding: NSUTF8StringEncoding]];
    [self appendBytes:"\0" length:1];
}

- (void)writeInt:(int)value {
    [self appendBytes:&value length:sizeof(value)];
}

- (void)writeUInt:(unsigned int)value {
    [self appendBytes:&value length:sizeof(value)];
}

- (void)writeFloat:(float)value {
    [self appendBytes:&value length:sizeof(value)];
}

- (void)writeColor:(NSColor*)color {
    [self writeUInt: SWColorEncode(color)];
}

@end

@implementation SWScene

+ (instancetype)import:(NSString*)path {
    SWScene* scene = [[SWScene alloc] init];
    NSData* data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:NULL];
    
    if (data == nil) {
        NSLog(@"Could not open scene file '%@'\n", path);
        return nil;
    }

    char header[4];
    [data readNextBytes:(unsigned char*)header length:4];
    
    if (strncmp(header, "SWAL", 4)) {
        NSLog(@"Invalid scene file\n");
        return nil;
    }
    
    // Read info

    scene.name = [data readNextString];
    scene.desc = [data readNextString];
    
    // Read video

    SWSceneVideo video;

    if ((video.dataLength = [data readNextUInt])) {
        video.filePath = [path cStringUsingEncoding: NSUTF8StringEncoding];
        video.dataLocation = (unsigned int)data.location;
        [data skip:video.dataLength];
        video.fps = [data readNextUInt];
        video.playbackSpeed = [data readNextFloat];
    }
    
    scene.video = video;
    
    // Read menu bar info

    SWSceneMenuBarInfo menuBarInfo;
    menuBarInfo.enabled = [data readNextInt];
    
    int colorsLength = [data readNextUInt];
    NSMutableArray* colors = [NSMutableArray array];
    
    for (int i = 0; i < colorsLength; ++i) {
        [colors addObject: [data readNextColor]];
    }
    
    menuBarInfo.colors = colors;
    menuBarInfo.effect = [data readNextInt];
    scene.menuBarInfo = menuBarInfo;
    
    return scene;
}

- (void)export:(NSString*)path {
    NSMutableData* data = [NSMutableData data];
    
    char* header = "SWAL";
    [data writeBytes:(unsigned char*)header length:strlen(header)];
    
    // Write info

    [data writeString:self.name];
    [data writeString:self.desc];

    // Write video
    
    bool hasVideo = true;
    
    if (!self.video.dataLocation) {
        // Importing from a video file
        NSData* videoData = [NSData dataWithContentsOfFile: [NSString stringWithCString:self.video.filePath encoding: NSUTF8StringEncoding]];
        [data writeUInt:(unsigned int)videoData.length];
        [data appendData: videoData];
    }
    else if (self.video.dataLength) {
        // Importing from the existing scene
        NSData* videoData = [NSData dataWithContentsOfFile: [NSString stringWithCString:self.video.filePath encoding: NSUTF8StringEncoding]];
        [data writeUInt:self.video.dataLength];
        [data appendData: [videoData subdataWithRange:NSMakeRange(self.video.dataLocation, self.video.dataLength)]];
    }
    else {
        hasVideo = false;
    }

    if (hasVideo) {
        [data writeUInt:self.video.fps];
        [data writeFloat:self.video.playbackSpeed];
    }

    // Write menu bar info
    
    [data writeInt:self.menuBarInfo.enabled];
    [data writeUInt:(int)self.menuBarInfo.colors.count];
    
    for (NSColor* color in self.menuBarInfo.colors) {
        [data writeColor: color];
    }
    
    [data writeInt:self.menuBarInfo.effect];

    if ([data writeToFile:path atomically:YES] == NO) {
        NSLog(@"Failed to export scene to %@\n", path);
    }
}

@end
