#import <SWColorUtils.h>

unsigned int SWColorEncode(NSColor* color) {
    color = [color colorUsingColorSpace: [NSColorSpace sRGBColorSpace]];
    return ((int)(color.redComponent * 255) << 24) | ((int)(color.greenComponent * 255) << 16) | ((int)(color.blueComponent * 255) << 8) | (int)(color.alphaComponent * 255);
}

NSColor* SWColorDecode(long encoded) {
    return [NSColor colorWithCalibratedRed:((encoded >> 24) & 0xFF) / 255.0 green:((encoded >> 16) & 0xFF) / 255.0 blue:((encoded >> 8) & 0xFF) / 255.0 alpha:(encoded & 0xFF) / 255.0];
}
