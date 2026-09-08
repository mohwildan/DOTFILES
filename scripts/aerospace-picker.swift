import Cocoa

// ==============================================================================
// 🚀 AeroSpace Spotlight-Style Interactive Window Picker & Auto-Jumper
// ==============================================================================

struct WinItem {
    let id: String
    let app: String
    let title: String
    let isFocused: Bool
}

class CustomPanel: NSPanel {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
}

class PickerView: NSView {
    var items: [WinItem] = []
    var selectedIndex: Int = 0
    var wsName: String = "Workspace"
    var onSelect: ((String) -> Void)?
    var onCancel: (() -> Void)?
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let headerHeight: CGFloat = 42
        let rowHeight: CGFloat = 40
        let footerHeight: CGFloat = 30
        
        // 1. Draw Header
        let headerTitle = "📁 Space: \(wsName)  •  \(items.count) Available Windows"
        let headerAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        (headerTitle as NSString).draw(at: NSPoint(x: 18, y: bounds.height - headerHeight + 13), withAttributes: headerAttr)
        
        // Header Divider
        let divPath = NSBezierPath()
        divPath.move(to: NSPoint(x: 16, y: bounds.height - headerHeight))
        divPath.line(to: NSPoint(x: bounds.width - 16, y: bounds.height - headerHeight))
        NSColor(white: 1.0, alpha: 0.12).setStroke()
        divPath.lineWidth = 1
        divPath.stroke()
        
        // 2. Draw Rows
        for (i, it) in items.enumerated() {
            let rowY = bounds.height - headerHeight - CGFloat(i + 1) * rowHeight + 3
            let rowRect = NSRect(x: 10, y: rowY, width: bounds.width - 20, height: rowHeight - 4)
            
            if i == selectedIndex {
                let bgPath = NSBezierPath(roundedRect: rowRect, xRadius: 8, yRadius: 8)
                NSColor(red: 0.18, green: 0.52, blue: 0.95, alpha: 0.38).setFill()
                bgPath.fill()
                NSColor(red: 0.35, green: 0.72, blue: 1.0, alpha: 0.65).setStroke()
                bgPath.lineWidth = 1.2
                bgPath.stroke()
            }
            
            // Number badge [1], [2]
            let numBadge = "[\(i + 1)]"
            let numAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 11.5, weight: .bold),
                .foregroundColor: (i == selectedIndex) ? NSColor(red: 0.45, green: 0.88, blue: 1.0, alpha: 1.0) : NSColor(white: 0.55, alpha: 1.0)
            ]
            (numBadge as NSString).draw(at: NSPoint(x: rowRect.minX + 10, y: rowRect.minY + 9), withAttributes: numAttr)
            
            // App Name
            let appAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 13, weight: .bold),
                .foregroundColor: NSColor.white
            ]
            (it.app as NSString).draw(at: NSPoint(x: rowRect.minX + 38, y: rowRect.minY + 9), withAttributes: appAttr)
            
            // Window Title
            let appWidth = (it.app as NSString).size(withAttributes: appAttr).width
            let titleX = rowRect.minX + 38 + appWidth + 12
            let maxTitleWidth = rowRect.maxX - titleX - (it.isFocused ? 78 : 14)
            
            if maxTitleWidth > 40 && !it.title.isEmpty {
                let titleAttr: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: NSColor(white: 0.65, alpha: 1.0)
                ]
                var cleanTitle = it.title.trimmingCharacters(in: .whitespacesAndNewlines)
                if cleanTitle.count > 46 {
                    cleanTitle = String(cleanTitle.prefix(43)) + "..."
                }
                (cleanTitle as NSString).draw(at: NSPoint(x: titleX, y: rowRect.minY + 9), withAttributes: titleAttr)
            }
            
            // Active badge
            if it.isFocused {
                let activeAttr: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 10, weight: .bold),
                    .foregroundColor: NSColor(red: 0.35, green: 0.92, blue: 0.55, alpha: 1.0)
                ]
                ("● Active" as NSString).draw(at: NSPoint(x: rowRect.maxX - 62, y: rowRect.minY + 11), withAttributes: activeAttr)
            }
        }
        
        // 3. Draw Footer
        let footerDiv = NSBezierPath()
        footerDiv.move(to: NSPoint(x: 16, y: footerHeight))
        footerDiv.line(to: NSPoint(x: bounds.width - 16, y: footerHeight))
        NSColor(white: 1.0, alpha: 0.1).setStroke()
        footerDiv.lineWidth = 1
        footerDiv.stroke()
        
        let maxKey = min(9, items.count)
        let footerText = "Press [1–\(maxKey)] to Auto-Jump  •  ↑/↓ or j/k to browse  •  ↵ Jump  •  Esc Dismiss"
        let footerAttr: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10.5, weight: .medium),
            .foregroundColor: NSColor(white: 0.48, alpha: 1.0)
        ]
        let footerSize = (footerText as NSString).size(withAttributes: footerAttr)
        (footerText as NSString).draw(at: NSPoint(x: (bounds.width - footerSize.width) / 2, y: 7), withAttributes: footerAttr)
    }
    
    override func keyDown(with event: NSEvent) {
        let code = event.keyCode
        
        // Escape
        if code == 53 {
            onCancel?()
            return
        }
        
        // Return / Space
        if code == 36 || code == 49 {
            if selectedIndex >= 0 && selectedIndex < items.count {
                onSelect?(items[selectedIndex].id)
            }
            return
        }
        
        // Up Arrow or k
        if code == 126 || event.characters == "k" {
            selectedIndex = (selectedIndex - 1 + items.count) % items.count
            needsDisplay = true
            return
        }
        
        // Down Arrow or j
        if code == 125 || event.characters == "j" {
            selectedIndex = (selectedIndex + 1) % items.count
            needsDisplay = true
            return
        }
        
        // Number keys 1-9 for INSTANT AUTO-JUMP!
        if let char = event.characters?.first, let num = Int(String(char)), num >= 1, num <= items.count {
            onSelect?(items[num - 1].id)
            return
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let pt = convert(event.locationInWindow, from: nil)
        let headerHeight: CGFloat = 42
        let rowHeight: CGFloat = 40
        
        for (i, _) in items.enumerated() {
            let rowY = bounds.height - headerHeight - CGFloat(i + 1) * rowHeight + 3
            let rowRect = NSRect(x: 10, y: rowY, width: bounds.width - 20, height: rowHeight - 4)
            if rowRect.contains(pt) {
                onSelect?(items[i].id)
                return
            }
        }
    }
}

// Kill any previous instance of aerospace-picker
let myPID = getpid()
let killTask = Process()
killTask.launchPath = "/bin/sh"
killTask.arguments = ["-c", "pgrep -f aerospace-picker | grep -v \(myPID) | xargs kill -9 2>/dev/null || true"]
try? killTask.run()
killTask.waitUntilExit()

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// 1. Fetch Windows in focused workspace from AeroSpace
let task = Process()
task.launchPath = "/opt/homebrew/bin/aerospace"
task.arguments = ["list-windows", "--workspace", "focused", "--format", "%{window-id}|%{app-name}|%{window-title}"]
let pipe = Pipe()
task.standardOutput = pipe
try? task.run()
task.waitUntilExit()

let data = pipe.fileHandleForReading.readDataToEndOfFile()
guard let output = String(data: data, encoding: .utf8) else { exit(0) }

let focusedTask = Process()
focusedTask.launchPath = "/opt/homebrew/bin/aerospace"
focusedTask.arguments = ["list-windows", "--focused", "--format", "%{window-id}"]
let focusedPipe = Pipe()
focusedTask.standardOutput = focusedPipe
try? focusedTask.run()
focusedTask.waitUntilExit()
let focusedId = String(data: focusedPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

let wsTask = Process()
wsTask.launchPath = "/opt/homebrew/bin/aerospace"
wsTask.arguments = ["list-workspaces", "--focused"]
let wsPipe = Pipe()
wsTask.standardOutput = wsPipe
try? wsTask.run()
wsTask.waitUntilExit()
let wsName = String(data: wsPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Workspace"

var items: [WinItem] = []
var initialSelectIndex = 0
for line in output.components(separatedBy: "\n") {
    let parts = line.components(separatedBy: "|")
    if parts.count >= 2 {
        let wid = parts[0].trimmingCharacters(in: .whitespaces)
        let app = parts[1].trimmingCharacters(in: .whitespaces)
        let title = parts.count > 2 ? parts[2].trimmingCharacters(in: .whitespaces) : ""
        if !wid.isEmpty && !app.isEmpty {
            if wid == focusedId { initialSelectIndex = items.count }
            items.append(WinItem(id: wid, app: app, title: title, isFocused: wid == focusedId))
        }
    }
}

if items.isEmpty { exit(0) }

// Calculate dimensions
let headerHeight: CGFloat = 42
let rowHeight: CGFloat = 40
let footerHeight: CGFloat = 30
let panelHeight = headerHeight + CGFloat(items.count) * rowHeight + footerHeight
let panelWidth: CGFloat = 540

guard let screen = NSScreen.main else { exit(0) }
let screenFrame = screen.visibleFrame
let x = screenFrame.midX - panelWidth / 2
let y = screenFrame.midY - panelHeight / 2 + 50

let panel = CustomPanel(
    contentRect: NSRect(x: x, y: y, width: panelWidth, height: panelHeight),
    styleMask: [.nonactivatingPanel, .borderless],
    backing: .buffered,
    defer: false
)
panel.level = .floating
panel.isOpaque = false
panel.backgroundColor = .clear
panel.hasShadow = true
panel.hidesOnDeactivate = true

let visualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight))
visualEffect.material = .hudWindow
visualEffect.blendingMode = .behindWindow
visualEffect.state = .active
visualEffect.wantsLayer = true
visualEffect.layer?.cornerRadius = 14
visualEffect.layer?.masksToBounds = true
visualEffect.layer?.borderColor = NSColor(white: 1.0, alpha: 0.18).cgColor
visualEffect.layer?.borderWidth = 1.0

let pickerView = PickerView(frame: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight))
pickerView.items = items
pickerView.wsName = wsName
pickerView.selectedIndex = initialSelectIndex

pickerView.onSelect = { winId in
    let jumpTask = Process()
    jumpTask.launchPath = "/opt/homebrew/bin/aerospace"
    jumpTask.arguments = ["focus", "--window-id", winId]
    try? jumpTask.run()
    jumpTask.waitUntilExit()
    exit(0)
}

pickerView.onCancel = {
    exit(0)
}

visualEffect.addSubview(pickerView)
panel.contentView = visualEffect
panel.makeKeyAndOrderFront(nil)
NSApp.activate(ignoringOtherApps: true)

// Dismiss on clicking outside
NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: .main) { _ in
    exit(0)
}

app.run()
