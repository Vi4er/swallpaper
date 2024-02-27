#import <appDelegate.h>
#import <menuBar.h>

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* application = [NSApplication sharedApplication];

        NSScreen* screen = [NSScreen mainScreen];
        NSWindow* window = [[NSWindow alloc] initWithContentRect: screen.frame styleMask: NSWindowStyleMaskBorderless backing: NSBackingStoreBuffered defer: NO];
        window.level = kCGDesktopWindowLevel;
        [window orderFront: window];

        ApplicationDelegate* appDelegate = [[ApplicationDelegate alloc] init];
        appDelegate.renderer = [Renderer newWithWindow:window];
        appDelegate.renderer.videoDecoder = video_decoder_new("/Users/user/Downloads/sunset-pink-ocean-moewalls-com.mp4", 1);
        
        MenuBarHandler* menuBarHandler = [[MenuBarHandler alloc] init];
        MenuBarWindow* menuBarWindow = [MenuBarWindow newWithMenuBarHandler:menuBarHandler];
        
        // Left side menu bar

        
        
        // Right side menu bar

        /*CFArrayRef windowList = CGWindowListCreate(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
        CFArrayRef windowInfoArray = CGWindowListCreateDescriptionFromArray(windowList);
        
        for (int i = 0; i < CFArrayGetCount(windowInfoArray); ++i) {
            CFDictionaryRef info = CFArrayGetValueAtIndex(windowInfoArray, i);
            CFDictionaryRef boundsDict = CFDictionaryGetValue(info, kCGWindowBounds);
            NSString* name = CFDictionaryGetValue(info, kCGWindowOwnerName);
            
            CFNumberRef layer = CFDictionaryGetValue(info, kCGWindowLayer);
            int num;
            if (!CFNumberGetValue(layer, kCFNumberIntType, &num) || num != 25) {
                continue;
            }

            CGRect bounds;

            if (CGRectMakeWithDictionaryRepresentation(boundsDict, &bounds) && bounds.origin.y == 0) {
                NSLog(@"%d %@ %x %x %x %x", num, name, bounds.origin.y, bounds.size.width, bounds.size.height);
            }
        }*/

        /*CGFloat totalWidth = 0.0;
        for (NSInteger i = 0; i < CFArrayGetCount(menuBarItems); i++) {
            AXUIElementRef menuItem = CFArrayGetValueAtIndex(menuBarItems, i);

            CGSize menuItemSize;
            AXUIElementCopyAttributeValue(menuItem, kAXSizeAttribute, (CFTypeRef *)&menuItemSize);
            
            totalWidth += menuItemSize.width;
        }*/
    
        /*
         NSRect frame = NSMakeRect(0, screen.frame.size.height - 36, screen.frame.size.width, 50);
         SWWindow* window2 = [[SWWindow alloc] initWithContentRect: frame styleMask: NSWindowStyleMaskBorderless backing: NSBackingStoreBuffered defer: NO];
         window2.level = CGWindowLevelForKey(kCGMaximumWindowLevelKey);
         window2.ignoresMouseEvents = YES;
         [window2 orderFront: window];
         
         // Calculate parameters for the capsules
         CGFloat capsuleWidth = self.window.frame.size.width / 2;
         CGFloat capsuleHeight = self.window.frame.size.height;

         // First Capsule
         NSBezierPath* path1 = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, capsuleWidth, capsuleHeight)
                                                              xRadius:capsuleWidth / 2
                                                              yRadius:capsuleHeight / 2];

         // Second Capsule
         NSBezierPath* path2 = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(capsuleWidth, 0, capsuleWidth, capsuleHeight)
                                                              xRadius:capsuleWidth / 2
                                                              yRadius:capsuleHeight / 2];
         
         [path1 appendBezierPath:path2];
         
         CAShapeLayer* maskLayer = [CAShapeLayer layer];
         maskLayer.path = [path1 CGPath];
         
         self.layer.mask = maskLayer;
         */

        [application setDelegate: appDelegate];
        [application run];
        
        video_decoder_free(appDelegate.renderer.videoDecoder);
    }

    return 0;
}
