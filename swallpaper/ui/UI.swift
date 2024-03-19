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
    var statusItem: NSStatusItem!
    
    @objc func show() {
        window = NSWindow(contentRect: NSMakeRect(0, 0, 720, 405), styleMask: [.fullSizeContentView, .closable, .miniaturizable, .titled], backing: .buffered, defer: false)
        window.title = "Swallpaper"
        window.delegate = windowDelegate
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        window.minSize = NSSize(width: 720, height: 405)

        window.contentViewController = NSHostingController(rootView: OnboardingScreen().frame(width: window.frame.size.width, height: window.frame.size.height))
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
        statusItem.button?.image = .menuBarIcon
        
        let statusMenu = NSMenu(title: "Swallpaper")
        statusItem.menu = statusMenu

//
//        let logoIcon = statusMenu.addItem(
//            withTitle: "Swallpaper",
//            action: #selector(showWindow(_:)),
//            keyEquivalent: ""
//        )
//
//        logoIcon.image = .menuBarIconGray
//        
//        statusMenu.addItem(.separator())
//        
//        statusMenu.addItem(
//            withTitle: "Show UI",
//            action: #selector(showWindow(_:)),
//            keyEquivalent: ""
//        ).target = self
//        
//        statusMenu.addItem(
//            withTitle: "Quit",
//            action: #selector(quit(_:)),
//            keyEquivalent: ""
//        ).target = self
        
        let statusItem = NSMenuItem()
        let view = NSHostingView(rootView: MenuBarView())
        view.frame = NSMakeRect(0, 0, 300, 250)
        statusItem.view = view
        statusItem.target = self
        statusMenu.addItem(statusItem)
        
        window.alphaValue = 0
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.75
            window.animator().alphaValue = 1
        }, completionHandler: nil)
    }
    
    @objc func showWindow(_ sender: Any?) {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit(_ sender: Any?) {
        exit(0)
    }
}
