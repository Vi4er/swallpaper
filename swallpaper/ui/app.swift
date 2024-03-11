import Foundation
import AppKit
import SnapKit
import SwiftUI

class WindowDelegate : NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }
}

@objc class UI : NSObject {
    var window: NSWindow!
    let windowDelegate = WindowDelegate()
    var statusItem: NSStatusItem!
    
    @objc func show() {
        window = NSWindow(contentRect: NSMakeRect(0, 0, 720, 405), styleMask: [.resizable, .fullSizeContentView, .titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Swallpaper"
        window.delegate = windowDelegate
        window.makeKeyAndOrderFront(nil)
        
        window.minSize = NSSize(width: 720, height: 405)

        window.contentViewController = NSHostingController(rootView: RootView())
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
        statusItem.button?.image = .menuBarIcon
        
        let statusMenu = NSMenu(title: "Swallpaper")
        statusItem.menu = statusMenu
        
        let logoIcon = statusMenu.addItem(
            withTitle: "Swallpaper",
            action: #selector(showWindow(_:)),
            keyEquivalent: ""
        )

        logoIcon.image = .menuBarIconGray
        
        statusMenu.addItem(.separator())
        
        statusMenu.addItem(
            withTitle: "Show UI",
            action: #selector(showWindow(_:)),
            keyEquivalent: ""
        ).target = self
        
        statusMenu.addItem(
            withTitle: "Quit",
            action: #selector(quit(_:)),
            keyEquivalent: ""
        ).target = self
    }
    
    @objc func showWindow(_ sender: Any?) {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit(_ sender: Any?) {
        exit(0)
    }
}
