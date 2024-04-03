#import <SWScene.h>
#import <SWColorUtils.h>

@implementation SWDataReader

#define READ_TYPE(type) type result; \
int size = sizeof(result); \
if (self.location + size > self.data.length) { return 0; } \
[self.data getBytes:&result range:NSMakeRange(self.location, size)]; \
_location += size; \
return result;

- (instancetype)initWithData:(NSData*)data {
    self = [super init];
    
    if (self) {
        _data = data;
    }
    
    return self;
}

- (void)skip:(int)amount {
    if (self.location + amount > self.data.length) {
        return;
    }
    
    _location += amount;
}

- (NSUInteger)readNextBytes:(unsigned char*)buffer length:(NSUInteger)length {
    NSUInteger readLength = MIN(length, self.data.length - self.location);
    
    if (readLength > 0) {
        [self.data getBytes:buffer range:NSMakeRange(self.location, readLength)];
        _location += readLength;
    }
    
    return readLength;
}

- (NSString*)readNextString {
    if (self.location >= self.data.length) {
        return nil;
    }

    const char* bytes = self.data.bytes + self.location;
    unsigned long strLength = strlen(bytes);
    
    if (strLength < self.data.length - self.location) {
        NSString* string = [[NSString alloc] initWithBytes:bytes length:strLength encoding:NSUTF8StringEncoding];
        _location += strLength + 1;
        
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

@end

@implementation SWDataWriter

- (instancetype)initWithData:(NSMutableData*)data {
    self = [super init];
    
    if (self) {
        _data = data;
    }
    
    return self;
}

- (void)writeBytes:(unsigned char*)buffer length:(NSUInteger)length {
    [self.data appendBytes:buffer length:length];
}

- (void)writeString:(NSString*)string {
    [self.data appendData: [string dataUsingEncoding: NSUTF8StringEncoding]];
    [self.data appendBytes:"\0" length:1];
}

- (void)writeInt:(int)value {
    [self.data appendBytes:&value length:sizeof(value)];
}

- (void)writeUInt:(unsigned int)value {
    [self.data appendBytes:&value length:sizeof(value)];
}

- (void)writeFloat:(float)value {
    [self.data appendBytes:&value length:sizeof(value)];
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
    
    SWDataReader* reader = [[SWDataReader alloc] initWithData:data];
    
    char header[4];
    [reader readNextBytes:(unsigned char*)header length:4];
    
    if (strncmp(header, "SWAL", 4)) {
        NSLog(@"Invalid scene file\n");
        return nil;
    }
    
    // Read info

    scene.name = [reader readNextString];
    scene.desc = [reader readNextString];
    
    // Read video

    SWSceneVideo video;

    if ((video.dataLength = [reader readNextUInt])) {
        video.filePath = [path cStringUsingEncoding: NSUTF8StringEncoding];
        video.dataLocation = reader.location;
        [reader skip:video.dataLength];
        video.fps = [reader readNextUInt];
        video.playbackSpeed = [reader readNextFloat];
    }
    
    scene.video = video;
    
    // Read menu bar info

    SWSceneMenuBarInfo menuBarInfo;
    menuBarInfo.enabled = [reader readNextInt];
    
    int colorsLength = [reader readNextUInt];
    NSMutableArray* colors = [NSMutableArray array];
    
    for (int i = 0; i < colorsLength; ++i) {
        [colors addObject: [reader readNextColor]];
    }
    
    menuBarInfo.colors = colors;
    menuBarInfo.effect = [reader readNextInt];
    scene.menuBarInfo = menuBarInfo;
    
    return scene;
}

- (void)export:(NSString*)path {
    NSMutableData* data = [[NSMutableData alloc] init];
    SWDataWriter* writer = [[SWDataWriter alloc] initWithData:data];
    
    char* header = "SWAL";
    [writer writeBytes:(unsigned char*)header length:strlen(header)];
    
    // Write info

    [writer writeString:self.name];
    [writer writeString:self.desc];

    // Write video
    
    bool hasVideo = true;
    
    if (!self.video.dataLocation) {
        // Importing from a video file
        NSData* videoData = [NSData dataWithContentsOfFile: [NSString stringWithCString:self.video.filePath encoding: NSUTF8StringEncoding]];
        [writer writeUInt:(unsigned int)videoData.length];
        [data appendData: videoData];
    }
    else if (self.video.dataLength) {
        // Importing from the existing scene
        NSData* videoData = [NSData dataWithContentsOfFile: [NSString stringWithCString:self.video.filePath encoding: NSUTF8StringEncoding]];
        [writer writeUInt:self.video.dataLength];
        [data appendData: [videoData subdataWithRange:NSMakeRange(self.video.dataLocation, self.video.dataLength)]];
    }
    else {
        hasVideo = false;
    }

    if (hasVideo) {
        [writer writeUInt:self.video.fps];
        [writer writeFloat:self.video.playbackSpeed];
    }

    // Write menu bar info
    
    [writer writeInt:self.menuBarInfo.enabled];
    [writer writeUInt:(int)self.menuBarInfo.colors.count];
    
    for (NSColor* color in self.menuBarInfo.colors) {
        [writer writeColor: color];
    }
    
    [writer writeInt:self.menuBarInfo.effect];

    if ([data writeToFile:path atomically:YES] == NO) {
        NSLog(@"Failed to export scene to %@\n", path);
    }
}

@end
