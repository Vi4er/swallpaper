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
    @objc var window: NSWindow!
    let windowDelegate = WindowDelegate()
    private var statusItem: NSStatusItem?
    private var popover = NSPopover()

    @objc func show() {
        window = NSWindow(contentRect: NSMakeRect(0, 0, 720, 405), styleMask: [.fullSizeContentView, .closable, .miniaturizable, .titled, .resizable], backing: .buffered, defer: false)
        window.title = "Swallpaper"
        window.delegate = windowDelegate
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.minSize = NSSize(width: 720, height: 405)
        window.contentViewController = NSHostingController(rootView: ContentView().frame(minWidth: 720, minHeight: 405))

        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: MenuBarView())
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let menuButton = statusItem?.button {
            menuButton.image = .menuBarIcon
            menuButton.action = #selector(menuToggle)
            menuButton.target = self
        }
        
        window.alphaValue = 0
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.75
            window.animator().alphaValue = 1
        }, completionHandler: nil)
        
        window.miniaturize(nil)
    }
    
    @objc func showWindow(_ sender: Any?) {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit(_ sender: Any?) {
        exit(0)
    }
    
    @objc private func menuToggle(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(sender)
            return
        }
        
        if let menuButton = statusItem?.button {
            self.popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
