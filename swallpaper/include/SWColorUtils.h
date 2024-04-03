#pragma once
#import <AppKit/AppKit.h>

unsigned int SWColorEncode(NSColor* color);
NSColor* SWColorDecode(long encoded);
