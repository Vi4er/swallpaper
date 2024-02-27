#import <menuBar.h>
#import <AppKit/AppKit.h>

@implementation MenuBarWindow

- (CGFloat)getMenuBarHeight {
    return self.screen.frame.size.height - self.screen.visibleFrame.size.height - (self.screen.visibleFrame.origin.y - self.screen.frame.origin.y) - 1;
}

- (void)updatePositionAndSize:(CGRect*)rect {
    CGFloat menuBarHeight = [self getMenuBarHeight];
    CGFloat height = menuBarHeight / 1.75;
    
    [self setFrame: CGRectMake(rect->origin.x, self.screen.frame.size.height - menuBarHeight + (menuBarHeight - height) / 2, rect->size.width, height) display:YES];
}

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen {
    return frameRect;
}

- (instancetype)initWithMenuBarHandler:(MenuBarHandler*)handler {
    self = [super init];
    
    if (self) {
        self.styleMask = NSWindowStyleMaskBorderless;
        self.backingType = NSBackingStoreBuffered;
        self.level = kCGMaximumWindowLevel;
        self.ignoresMouseEvents = YES;
        self.backgroundColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5];
        self.hasShadow = NO;

        CGRect leftMenuBarRect = [handler getLeftMenuBarRect];
        [self updatePositionAndSize: &leftMenuBarRect];
        [self orderFront: self];

        [handler.windows addObject: self];
    }
    
    return self;
}

+ (instancetype)newWithMenuBarHandler:(MenuBarHandler*)handler {
    return [[self alloc] initWithMenuBarHandler:handler];
}

@end

@implementation MenuBarHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                                selector:@selector(appDidActivate:)
                                                                name:NSWorkspaceDidActivateApplicationNotification
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

    return CGRectMake(0, 0, 0, 0);
}

- (void)appDidActivate:(NSNotification *)notification {
    CGRect leftMenuBarRect = [self getLeftMenuBarRect];

    for (int i = 0; i < self.windows.count; ++i) {
        [self.windows[i] updatePositionAndSize:&leftMenuBarRect];
    }
}

- (void)dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

@end
