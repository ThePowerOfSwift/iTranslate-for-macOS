import Cocoa
import ServiceManagement
import GoogleReporter

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var timer: Timer!
    let pasteboard: NSPasteboard = .general
    var lastChangeCount: Int = 0

    @IBOutlet weak var popover: NSPopover!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        showPopover(popover)
        
        // GA埋点的e配置代码
        GoogleReporter.shared.configure(withTrackerId: "UA-158042469-2")
        
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("statusIcon"))
            button.action = #selector(togglePopover)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (t) in
            if self.lastChangeCount != self.pasteboard.changeCount {
                self.lastChangeCount = self.pasteboard.changeCount
                NotificationCenter.default.post(name: .NSPasteboardDidChange, object: self.pasteboard)
            }
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        timer.invalidate()
    }
    
    // 设置快捷键
    @objc func hotkeyCalled() {
        print("HotKey called!!!!")
    }
    
    @objc func quitApp(_ sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func showPopover(_ sender: AnyObject) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
        
    @objc func closePopover(_ sender: AnyObject) {
        popover.performClose(sender)
    }
        
    @objc func togglePopover(_ sender: AnyObject) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}

extension NSNotification.Name {
    public static let NSPasteboardDidChange: NSNotification.Name = .init(rawValue: "pasteboardDidChangeNotification")
    // 向后台常驻程序传递信息，通知关闭后台程序
    static let killLauncher = Notification.Name("killLauncher")
}

extension NSTextField {
    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.isDisjoint(with: .command) {
            return super.performKeyEquivalent(with: event)
        }
        
        switch event.charactersIgnoringModifiers {
        case "a":
            return NSApp.sendAction(#selector(NSText.selectAll(_:)), to: self.window?.firstResponder, from: self)
        case "c":
            return NSApp.sendAction(#selector(NSText.copy(_:)), to: self.window?.firstResponder, from: self)
        case "v":
            return NSApp.sendAction(#selector(NSText.paste(_:)), to: self.window?.firstResponder, from: self)
        case "x":
            return NSApp.sendAction(#selector(NSText.cut(_:)), to: self.window?.firstResponder, from: self)
        default:
            return super.performKeyEquivalent(with: event)
        }
    }
}
