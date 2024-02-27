#import <menuBar.h>
#import <AppKit/AppKit.h>

@implementation MenuBarWindow

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen {
    return frameRect;
}

- (instancetype)initWithMenuBarHandler: (MenuBarHandler*)handler {
    self = [super init];
    
    if (self) {
        self.menuBarHandler = handler;
        
        CGRect leftMenuBarRect = [handler getLeftMenuBarRect];
        
        self.styleMask = NSWindowStyleMaskBorderless;
        self.backingType = NSBackingStoreBuffered;
        self.level = CGWindowLevelForKey(kCGMaximumWindowLevelKey);
        self.ignoresMouseEvents = YES;
        self.backgroundColor = [NSColor colorWithCalibratedRed:1 green:0 blue:0 alpha:0.5];
        [self setContentSize: leftMenuBarRect.size];
        [self setFrameOrigin: CGPointMake(leftMenuBarRect.origin.x, self.screen.frame.size.height - 34)];
        [self orderFront: self];
        
        [self.menuBarHandler.windows addObject: self];
    }
    
    return self;
}

+ (instancetype)newWithMenuBarHandler: (MenuBarHandler*)handler {
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
        CFIndex itemCount;
        AXUIElementGetAttributeValueCount(appMenuBar, kAXChildrenAttribute, &itemCount);

        CFArrayRef objectChildren;
        AXUIElementCopyAttributeValue(appMenuBar, kAXChildrenAttribute, (CFTypeRef*)&objectChildren);

        CGFloat width = 0.0;

        for (CFIndex i = 0; i < itemCount; ++i) {
            AXUIElementRef menuItem = CFArrayGetValueAtIndex(objectChildren, i);
            
            if (menuItem) {
                AXValueRef sizeRef;
                AXUIElementCopyAttributeValue(menuItem, kAXSizeAttribute, (CFTypeRef*)&sizeRef);

                if (sizeRef) {
                    CGSize size;

                    if (AXValueGetValue(sizeRef, kAXValueCGSizeType, &size)) {
                        width += size.width;
                    }

                    CFRelease(sizeRef);
                }
            }
        }

        AXUIElementRef menuItem = CFArrayGetValueAtIndex(objectChildren, 0);
        AXValueRef posRef;
        AXUIElementCopyAttributeValue(menuItem, kAXPositionAttribute, (CFTypeRef*)&posRef);

        CGPoint pos;
        AXValueGetValue(posRef, kAXValueCGPointType, &pos);

        CFRelease(objectChildren);
        CFRelease(appMenuBar);
        
        return CGRectMake(pos.x, 0, width, 25); // TODO: Get menu bar height automatically
    }

    return CGRectMake(0, 0, 0, 0);
}

- (void)appDidActivate:(NSNotification *)notification {
    for (int i = 0; i < self.windows.count; ++i) {
        MenuBarWindow* window = self.windows[i];
        
        CGRect leftMenuBarRect = [self getLeftMenuBarRect];
        [window setContentSize: leftMenuBarRect.size];
        [window setFrameOrigin: CGPointMake(leftMenuBarRect.origin.x, window.screen.frame.size.height - 34)];
    }
}

- (void)dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

@end
