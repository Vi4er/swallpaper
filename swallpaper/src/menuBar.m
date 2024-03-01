#import <menuBar.h>
#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation NonConstrainedNSWindow

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen*)screen {
    return frameRect;
}

@end

@implementation MenuBarWindow

- (CGFloat)getMenuBarHeight {
    return self.screen.frame.size.height - self.screen.visibleFrame.size.height - (self.screen.visibleFrame.origin.y - self.screen.frame.origin.y) - 1;
}

- (void)updatePositionAndSize:(CGRect*)leftRect rightRect:(CGRect*)rightRect {
    CGFloat menuBarHeight = [self getMenuBarHeight];
    [self setFrame: NSMakeRect(0, self.screen.frame.size.height - menuBarHeight, self.screen.frame.size.width, menuBarHeight) display:NO];

    CGFloat capsuleHeight = menuBarHeight / 1.75;
    CGFloat centerY = (menuBarHeight - capsuleHeight) / 2;
    
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(leftRect->origin.x, centerY, leftRect->size.width, capsuleHeight)
                                                         xRadius:capsuleHeight / 2
                                                         yRadius:capsuleHeight / 2];

    [path appendBezierPath: [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(rightRect->origin.x, centerY, rightRect->size.width, capsuleHeight)
                                                             xRadius:capsuleHeight / 2
                                                             yRadius:capsuleHeight / 2]];

    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.path = [[NSBezierPath bezierPathWithRect: NSMakeRect(0, 0, self.frame.size.width, menuBarHeight)] CGPath];
    
    CAShapeLayer* bezierLayer = [CAShapeLayer layer];
    bezierLayer.path = [path CGPath];
    bezierLayer.compositingFilter = @"xor";
    [maskLayer addSublayer: bezierLayer];

    self.contentView.layer.mask = maskLayer;
}

- (instancetype)initWithMenuBarHandler:(MenuBarHandler*)handler screen:(NSScreen*)screen {
    self = [super initWithContentRect:NSMakeRect(0, 0, screen.frame.size.width, 1) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO screen:screen];
    
    if (self) {
        self.level = kCGMaximumWindowLevel;
        self.ignoresMouseEvents = YES;
        self.backgroundColor = [NSColor colorWithCalibratedRed:1 green:0 blue:0 alpha:0];
        self.hasShadow = NO;
        self.opaque = NO;

        CGRect leftMenuBarRect = [handler getLeftMenuBarRect];
        CGRect rightMenuBarRect = [handler getRightMenuBarRect];
        [self updatePositionAndSize: &leftMenuBarRect rightRect:&rightMenuBarRect];
        [self orderFront: self];

        [handler.windows addObject: self];
    }
    
    return self;
}

+ (instancetype)newWithMenuBarHandler:(MenuBarHandler*)handler screen:(NSScreen*)screen {
    return [[self alloc] initWithMenuBarHandler:handler screen:screen];
}

@end

@implementation MenuBarHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter* notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];

        [notificationCenter addObserver:self
                                selector:@selector(appDidActivate:)
                                name:NSWorkspaceDidActivateApplicationNotification
                                object:nil];
        
        [notificationCenter addObserver:self
                                selector:@selector(appDidActivate:)
                                name:NSWorkspaceDidLaunchApplicationNotification
                                object:nil];
        
        self.windows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (CGRect)getLeftMenuBarRect {
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

        return CGRectMake(leftPos.x, 0, rightPos.x - leftPos.x + rightSize.width, 0);
    }

    return CGRectMake(-1, -1, -1, -1);
}

- (CGRect)getRightMenuBarRect {
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
    
    return CGRectMake(leftX, 0, rightX - leftX - 10, 0);
}

- (void)appDidActivate:(NSNotification *)notification {
    CGRect leftMenuBarRect = [self getLeftMenuBarRect];
    CGRect rightMenuBarRect = [self getRightMenuBarRect];

    if (leftMenuBarRect.origin.x == -1) {
        return;
    }

    for (int i = 0; i < self.windows.count; ++i) {
        [self.windows[i] updatePositionAndSize:&leftMenuBarRect rightRect:&rightMenuBarRect];
    }
}

- (void)dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

@end
