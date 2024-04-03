#pragma once
#import <AppKit/AppKit.h>
#import <SWGradientLayer.h>

/*
 Swallpaper Scene Binary Format

 struct Video {
     int length;
     byte[] data;
     int fps;
     float playbackSpeed;
     
 }

 struct MenuBarInfo {
     bool enabled;
     int colorsLength;
     NSColor[] colors;
     SWGradientEffect effect;
 }

 * First 4 Bytes have to be SWAL
 * Strings can be shorter but no more than the specified length and must be null terminated

 Name            <String(64)>
 Description     <String(255)>
 Video           <Video>         // If length is 0, no video was specified and this can be skipped
 MenuBarInfo     <MenuBarInfo>

 */

@interface SWDataReader : NSObject

@property (readonly) NSData* data;
@property (readonly) int location;

- (instancetype)initWithData:(NSData*)data;

- (void)skip:(int)amount;
- (NSUInteger)readNextBytes:(unsigned char*)buffer length:(NSUInteger)length;
- (NSString*)readNextString;
- (int)readNextInt;
- (unsigned int)readNextUInt;
- (float)readNextFloat;
- (NSColor*)readNextColor;

@end

@interface SWDataWriter : NSObject

@property (readonly) NSMutableData* data;

- (instancetype)initWithData:(NSMutableData*)data;

- (void)writeBytes:(unsigned char*)buffer length:(NSUInteger)length;
- (void)writeString:(NSString*)string;
- (void)writeInt:(int)value;
- (void)writeUInt:(unsigned int)value;
- (void)writeFloat:(float)value;
- (void)writeColor:(NSColor*)color;

@end

typedef struct SWSceneVideo {
    const char* filePath; // Set to scene path for it to use the same data, or set to a video path to import the video into the scene
    unsigned int dataLocation;
    unsigned int dataLength;
    unsigned int fps;
    float playbackSpeed;
} SWSceneVideo;

typedef struct SWSceneMenuBarInfo {
    int enabled;
    NSArray<NSColor*>* colors;
    SWGradientEffect effect;
} SWSceneMenuBarInfo;

@interface SWScene : NSObject

@property NSString* name;
@property NSString* desc;

@property SWSceneVideo video;
@property SWSceneMenuBarInfo menuBarInfo;

+ (instancetype)import:(NSString*)path;
- (void)export:(NSString*)path;

@end
