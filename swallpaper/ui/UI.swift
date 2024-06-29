import SwiftUI
import SnapKit

class WindowDelegate : NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        NSApplication.shared.setActivationPolicy(.accessory)
        return false
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.regular)
    }
}

@objc class UI : NSObject {
    @objc static var window: NSWindow!
    static let windowDelegate = WindowDelegate()
    private static var statusItem: NSStatusItem?
    private static var popover = NSPopover()

    @objc static func setup() {
        window = NSWindow(contentRect: NSMakeRect(0, 0, 720, 405), styleMask: [.fullSizeContentView, .closable, .miniaturizable, .titled, .resizable], backing: .buffered, defer: false)
        window.title = "Swallpaper"
        window.delegate = windowDelegate
        window.minSize = NSSize(width: 720, height: 405)
        window.contentViewController = NSHostingController(rootView: ContentView().frame(minWidth: 720, minHeight: 405))

        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: MenuBarView())
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let menuButton = statusItem?.button {
            let image: NSImage = .menuBarIcon
            image.isTemplate = true
            menuButton.image = image
            menuButton.action = #selector(menuToggle)
            menuButton.target = self
        }
        
        // window.miniaturize(nil)
    }
    
    @objc static func showWindow(_ sender: Any?) {
        window.alphaValue = 0
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.75
            window.animator().alphaValue = 1
        }, completionHandler: nil)
        
        NSApp.activate()
    }
    
    @objc static private func menuToggle(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(sender)
            return
        }
        
        if let menuButton = statusItem?.button {
            popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
            // popover.contentViewController?.view.window?.makeKey()
        }
    }
}
