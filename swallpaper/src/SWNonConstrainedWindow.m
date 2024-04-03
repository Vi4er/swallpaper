#import <SWNonConstrainedWindow.h>

@implementation SWNonConstrainedWindow

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen*)screen {
    return frameRect;
}

@end

