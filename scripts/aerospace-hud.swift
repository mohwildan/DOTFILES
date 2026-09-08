import Cocoa

// Elegant, ultra-lightweight translucent floating HUD for macOS / AeroSpace
let msg = CommandLine.arguments.count > 1 ? CommandLine.arguments.dropFirst().joined(separator: " ") : "Workspace Info"
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// Terminate any previous HUD instances to avoid stacking
let myPID = getpid()
let pipe = Pipe()
let task = Process()
task.launchPath = "/bin/sh"
task.arguments = ["-c", "pgrep -f aerospace-hud | grep -v \(myPID) | xargs kill -9 2>/dev/null || true"]
try? task.run()
task.waitUntilExit()

guard let screen = NSScreen.main else { exit(0) }
let screenFrame = screen.visibleFrame

let font = NSFont.systemFont(ofSize: 13, weight: .medium)
let fontBold = NSFont.systemFont(ofSize: 13, weight: .bold)

// Calculate dynamic width based on message length
let estWidth = CGFloat(msg.count * 8 + 48)
let width = min(max(280, estWidth), screenFrame.width - 60)
let height: CGFloat = 38
let x = screenFrame.midX - width / 2
let y = screenFrame.maxY - height - 12

let panel = NSPanel(
    contentRect: NSRect(x: x, y: y, width: width, height: height),
    styleMask: [.nonactivatingPanel, .borderless],
    backing: .buffered,
    defer: false
)
panel.level = .floating
panel.isOpaque = false
panel.backgroundColor = .clear
panel.hasShadow = true
panel.ignoresMouseEvents = true

let visualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: width, height: height))
visualEffect.material = .hudWindow
visualEffect.blendingMode = .behindWindow
visualEffect.state = .active
visualEffect.wantsLayer = true
visualEffect.layer?.cornerRadius = 19
visualEffect.layer?.masksToBounds = true
visualEffect.layer?.borderColor = NSColor(white: 1.0, alpha: 0.15).cgColor
visualEffect.layer?.borderWidth = 1.0

let label = NSTextField(frame: NSRect(x: 16, y: 8, width: width - 32, height: 22))
label.stringValue = msg
label.font = font
label.textColor = NSColor(white: 0.95, alpha: 1.0)
label.alignment = .center
label.isBezeled = false
label.isEditable = false
label.drawsBackground = false
label.cell?.wraps = false
label.cell?.isScrollable = true

visualEffect.addSubview(label)
panel.contentView = visualEffect
panel.alphaValue = 0
panel.orderFrontRegardless()

// Smooth fade in
NSAnimationContext.runAnimationGroup({ context in
    context.duration = 0.15
    panel.animator().alphaValue = 1.0
})

// Auto fade out after 1.5s
DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
    NSAnimationContext.runAnimationGroup({ context in
        context.duration = 0.25
        panel.animator().alphaValue = 0
    }, completionHandler: {
        exit(0)
    })
}

app.run()
