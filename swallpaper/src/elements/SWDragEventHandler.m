#import <elements/SWDragEventHandler.h>
#import <AppKit/AppKit.h>
#import <SWWallpaper.h>

// TODO: Make this actually clean

@implementation SWDragEventHandler

+ (void)sendLeftEvent:(CGEventType)mouseType mouseCursorPosition:(CGPoint)mouseCursorPosition {
    CGEventRef event = CGEventCreateMouseEvent(NULL, mouseType, mouseCursorPosition, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}

+ (void)dragWorkaround {
    CGEventRef emptyEvent = CGEventCreate(NULL);
    CGPoint mousePosition = CGEventGetLocation(emptyEvent);
    CGPoint dragTo = mousePosition;
    dragTo.x += 5;

    [SWDragEventHandler sendLeftEvent:kCGEventLeftMouseDragged mouseCursorPosition:dragTo];
    [SWDragEventHandler sendLeftEvent:kCGEventLeftMouseUp mouseCursorPosition:dragTo];
    [SWDragEventHandler sendLeftEvent:kCGEventMouseMoved mouseCursorPosition:mousePosition];
    
    CFRelease(emptyEvent);
}

+ (int)isHoveringDesktop {
    NSInteger windowNumber = [NSWindow windowNumberAtPoint:NSEvent.mouseLocation belowWindowWithWindowNumber:0];
    CFArrayRef infoArray = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow, (CGWindowID)windowNumber);

    if (CFArrayGetCount(infoArray)) {
        CFDictionaryRef info = CFArrayGetValueAtIndex(infoArray, 0);
        
        int layer;
        if (CFNumberGetValue(CFDictionaryGetValue(info, kCGWindowLayer), kCFNumberIntType, &layer) && layer == kCGDesktopIconWindowLevel) {
            return 1;
        }
    }
    
    return 0;
}

+ (void)registerHandler {
    __block SWElement* draggingElement;
    __block CGPoint offset;

    [NSEvent addGlobalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown|NSEventMaskLeftMouseDragged) handler:^(NSEvent* event) {
        if (event.type == NSEventTypeLeftMouseDown) {
            if ([SWDragEventHandler isHoveringDesktop]) {
                for (SWWallpaper* wallpaper in [SWWallpaper wallpapers]) {
                    for (SWElement* child in wallpaper.children) {
                        offset = [wallpaper.layer convertPoint:NSEvent.mouseLocation toLayer:child.layer];
                        offset.y = wallpaper.layer.frame.size.height - NSEvent.mouseLocation.y - child.layer.frame.origin.y; // Flip y

                        if ([child.layer containsPoint:offset]) {
                            draggingElement = child;
                            [SWDragEventHandler dragWorkaround];
                            break;
                        }
                        else {
                            draggingElement = nil;
                        }
                    }
                }
            }
            else {
                draggingElement = nil;
            }
        }
        
        if (event.type == NSEventTypeLeftMouseDragged && draggingElement) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            SWWallpaper* wallpaper = (SWWallpaper*)draggingElement.parent;

            CGRect rect = draggingElement.layer.frame;
            rect.origin.x = MIN(MAX(
                                NSEvent.mouseLocation.x - offset.x,
                                0
                            ), wallpaper.layer.frame.size.width - draggingElement.layer.frame.size.width);
            rect.origin.y = MIN(MAX(
                                wallpaper.layer.frame.size.height - NSEvent.mouseLocation.y - offset.y,
                                wallpaper.menuBar.frame.size.height
                            ), wallpaper.layer.frame.size.height - draggingElement.layer.frame.size.height);
            draggingElement.layer.frame = rect;

            [CATransaction commit];
        }
    }];
}

@end
