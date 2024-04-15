#import <SWMenuBar.h>
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import <SWGradientLayer.h>

@implementation SWMenuBar

- (CGFloat)getMenuBarHeight {
    return self.screen.frame.size.height - self.screen.visibleFrame.size.height - (self.screen.visibleFrame.origin.y - self.screen.frame.origin.y) - 1;
}

- (void)updatePositionAndSize:(NSRect*)leftRect rightRect:(NSRect*)rightRect {
    CGFloat menuBarHeight = [self getMenuBarHeight];

    CGFloat capsuleHeight = menuBarHeight * 0.8; // menuBarHeight / 1.75;
    CGFloat centerY = (menuBarHeight - capsuleHeight) / 2;
    
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(leftRect->origin.x, centerY, leftRect->size.width, capsuleHeight)
                                                         xRadius:capsuleHeight / 2
                                                         yRadius:capsuleHeight / 2];

    [path appendBezierPath: [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(rightRect->origin.x, centerY, rightRect->size.width, capsuleHeight)
                                                            xRadius:capsuleHeight / 2
                                                            yRadius:capsuleHeight / 2]];

    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.path = [[NSBezierPath bezierPathWithRect: NSMakeRect(0, 0, self.screen.frame.size.width, menuBarHeight)] CGPath];
    
    CAShapeLayer* bezierLayer = [CAShapeLayer layer];
    bezierLayer.path = [path CGPath];
    bezierLayer.compositingFilter = @"xor";
    [maskLayer addSublayer: bezierLayer];

    self.contentView.layer.sublayers[0].mask = maskLayer;
    self.contentView.layer.sublayers[0].frame = self.contentView.layer.frame;
    
    [self setFrame: NSMakeRect(0, self.screen.frame.size.height - menuBarHeight, self.screen.frame.size.width, menuBarHeight) display:NO];
}

- (void)setGradient:(NSArray*)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    SWGradientLayer* layer = (SWGradientLayer*)self.contentView.layer;
    layer.startPoint = startPoint;
    layer.endPoint = endPoint;
    layer.colors = colors;
}

- (instancetype)initWithScreen:(NSScreen*)screen {
    self = [super initWithContentRect:NSMakeRect(0, 0, screen.frame.size.width, 1) styleMask:NSWindowStyleMaskBorderless|NSWindowStyleMaskNonactivatingPanel backing:NSBackingStoreBuffered defer:NO screen:screen];
    
    if (self) {
        self.level = kCGMaximumWindowLevel;
        self.ignoresMouseEvents = YES;
        self.backgroundColor = [NSColor clearColor];
        self.hasShadow = NO;

        self.contentView.layer = [SWGradientLayer layer];

        NSRect leftMenuBarRect = [SWMenuBar getLeftMenuBarRect];
        NSRect rightMenuBarRect = [SWMenuBar getRightMenuBarRect];
        [self updatePositionAndSize: &leftMenuBarRect rightRect: &rightMenuBarRect];
        [self orderFront: nil];
    }

    return self;
}

+ (instancetype)newWithScreen:(NSScreen*)screen {
    return [[self alloc] initWithScreen:screen];
}

+ (NSRect)getLeftMenuBarRect {
    NSRunningApplication* frontApp = [NSWorkspace.sharedWorkspace frontmostApplication];
    AXUIElementRef appMenuBar;

    if (AXUIElementCopyAttributeValue(AXUIElementCreateApplication(frontApp.processIdentifier), kAXMenuBarAttribute, (CFTypeRef*)&appMenuBar) == kAXErrorSuccess) {
        CFArrayRef objectChildren;
        AXUIElementCopyAttributeValue(appMenuBar, kAXChildrenAttribute, (CFTypeRef*)&objectChildren);

        AXValueRef valueRef;
        CGSize rightSize;
        CGPoint leftPos, rightPos;

        AXUIElementRef menuItem = CFArrayGetValueAtIndex(objectChildren, 0);
        
        if (menuItem && AXUIElementCopyAttributeValue(menuItem, kAXPositionAttribute, (CFTypeRef*)&valueRef) == kAXErrorSuccess) {
            AXValueGetValue(valueRef, kAXValueCGPointType, &leftPos);
            CFRelease(valueRef);
        }
        
        menuItem = CFArrayGetValueAtIndex(objectChildren, CFArrayGetCount(objectChildren) - 1);

        if (menuItem && AXUIElementCopyAttributeValue(menuItem, kAXPositionAttribute, (CFTypeRef*)&valueRef) == kAXErrorSuccess) {
            AXValueGetValue(valueRef, kAXValueCGPointType, &rightPos);
            CFRelease(valueRef);

            if (AXUIElementCopyAttributeValue(menuItem, kAXSizeAttribute, (CFTypeRef*)&valueRef) == kAXErrorSuccess) {
                AXValueGetValue(valueRef, kAXValueCGSizeType, &rightSize);
                CFRelease(valueRef);
            }
        }
        
        CFRelease(objectChildren);
        CFRelease(appMenuBar);

        return NSMakeRect(leftPos.x, 0, rightPos.x - leftPos.x + rightSize.width, 0);
    }

    return NSMakeRect(-1, -1, -1, -1);
}

+ (NSRect)getRightMenuBarRect {
    CFArrayRef windowList = CGWindowListCreate(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    CFArrayRef windowInfoArray = CGWindowListCreateDescriptionFromArray(windowList);
    
    CGFloat leftX = 0, rightX = 0;

    for (int i = 0; i < CFArrayGetCount(windowInfoArray); ++i) {
        CFDictionaryRef info = CFArrayGetValueAtIndex(windowInfoArray, i);

        int layer;
        if (!CFNumberGetValue(CFDictionaryGetValue(info, kCGWindowLayer), kCFNumberIntType, &layer) || layer != 25) {
            continue;
        }
        
        CFDictionaryRef boundsDict = CFDictionaryGetValue(info, kCGWindowBounds);
        CGRect bounds;

        if (CGRectMakeWithDictionaryRepresentation(boundsDict, &bounds) && bounds.origin.y == 0) {
            CGFloat left = bounds.origin.x;
            CGFloat right = left + bounds.size.width;
            
            if (left < leftX || leftX == 0) {
                leftX = left;
            }
   
            if (right > rightX) {
                rightX = right;
            }
        }
    }
    
    return NSMakeRect(leftX, 0, rightX - leftX - 10, 0);
}

@end
