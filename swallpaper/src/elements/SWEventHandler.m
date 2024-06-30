#import <elements/SWEventHandler.h>
#import <AppKit/AppKit.h>
#import <SWWallpaper.h>

// TODO: Make this actually clean

@implementation SWEventHandler

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

    [SWEventHandler sendLeftEvent:kCGEventLeftMouseDragged mouseCursorPosition:dragTo];
    [SWEventHandler sendLeftEvent:kCGEventLeftMouseUp mouseCursorPosition:mousePosition];
    [SWEventHandler sendLeftEvent:kCGEventMouseMoved mouseCursorPosition:mousePosition];
    
    CFRelease(emptyEvent);
}

+ (int)isHoveringDesktop {
    NSInteger windowNumber = [NSWindow windowNumberAtPoint:NSEvent.mouseLocation belowWindowWithWindowNumber:0];
    CFArrayRef infoArray = CGWindowListCopyWindowInfo(kCGWindowListOptionIncludingWindow, (CGWindowID)windowNumber);

    if (CFArrayGetCount(infoArray)) {
        CFDictionaryRef info = CFArrayGetValueAtIndex(infoArray, 0);
        
        int layer;
        if (CFNumberGetValue(CFDictionaryGetValue(info, kCGWindowLayer), kCFNumberIntType, &layer) && layer == kCGDesktopIconWindowLevel) {
            CFRelease(infoArray);
            return 1;
        }
    }
    
    CFRelease(infoArray);
    
    return 0;
}

+ (Boolean)isHovered: (SWElement*)element {
    NSPoint mouseLocation = NSEvent.mouseLocation;
    mouseLocation.y = [NSScreen mainScreen].frame.size.height - mouseLocation.y;

    SWElement* root = element.parent;
    while (root.parent) {
        root = root.parent;
    }

    CGPoint converted = [root.layer convertPoint:mouseLocation toLayer:element.layer];
    return [element.layer containsPoint:converted];
}

// TODO: Implement ZIndex and ignoresPointerEvents
+ (SWElement*)hoveredElement: (SWElement*)parent {
    for (SWElement* child in parent.children) {
        if ([[self class] isHovered:child]) {
            SWElement* hovered = [[self class] hoveredElement:child];
            
            if (hovered) {
                return hovered;
            }
            else {
                return child;
            }
        }
    }
    
    return nil;
}

+ (void)init {
    __block NSMutableArray<SWElement*>* hoveredElements = [NSMutableArray array];
    __block SWElement* draggingElement;
    __block CGPoint offset;
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown|NSEventMaskLeftMouseDragged|NSEventMaskMouseMoved) handler:^(NSEvent* event) {
        if (event.type == NSEventTypeLeftMouseDown) {
            if ([SWEventHandler isHoveringDesktop]) {
                for (SWWallpaper* wallpaper in [SWWallpaper wallpapers]) {
                    for (SWElement* child in wallpaper.children) {
                        if (!child.draggable) {
                            continue;
                        }

                        offset = [wallpaper.layer convertPoint:NSEvent.mouseLocation toLayer:child.layer];
                        offset.y = wallpaper.layer.frame.size.height - NSEvent.mouseLocation.y - child.layer.frame.origin.y; // Flip y

                        if ([child.layer containsPoint:offset]) {
                            draggingElement = child;
                            [SWEventHandler dragWorkaround];
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
        else if (event.type == NSEventTypeLeftMouseDragged && draggingElement) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            SWWallpaper* wallpaper = (SWWallpaper*)draggingElement.parent;

            SWRect rect = draggingElement.frame;
            rect.origin.x.scale = rect.origin.y.scale = 0;
            rect.origin.x.offset = MIN(MAX(
                                NSEvent.mouseLocation.x - offset.x,
                                0
                            ), wallpaper.layer.frame.size.width - draggingElement.layer.frame.size.width);
            rect.origin.y.offset = MIN(MAX(
                                wallpaper.layer.frame.size.height - NSEvent.mouseLocation.y - offset.y,
                                wallpaper.menuBar.frame.size.height
                            ), wallpaper.layer.frame.size.height - draggingElement.layer.frame.size.height);
            draggingElement.frame = rect;

            [CATransaction commit];
        }
        else if (event.type == NSEventTypeMouseMoved) {
            // TODO: Make work for multiple wallpapers (idk maybe get root parent as wallpaper)
            SWMouseEvent* event = [SWMouseEvent new];
            SWElement* hovered = [[self class] hoveredElement:[SWWallpaper wallpapers][0]];
            
            if (hovered && ![hoveredElements containsObject:hovered]) {
                event.type = kSWEventTypeMouseEnter;
                [hovered triggerEvent:event];
                [hoveredElements addObject:hovered];
            }
            
            for (NSUInteger i = hoveredElements.count; i > 0; --i) {
                SWElement* element = hoveredElements[i - 1];
                
                if (![[self class] isHovered:element]) {
                    event.type = kSWEventTypeMouseLeave;
                    [element triggerEvent:event];
                    [hoveredElements removeObject:element];
                }
            }
        }
    }];
}

@end
