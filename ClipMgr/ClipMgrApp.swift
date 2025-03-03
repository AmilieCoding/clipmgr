import SwiftUI
import AppKit

class ClipboardManager: ObservableObject {
    @Published var clipboardHistory: [String] = []
    private var timer: Timer?
    private var lastCopiedItem: String?
    
    init() {
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        if let copiedString = NSPasteboard.general.string(forType: .string), copiedString != lastCopiedItem {
            lastCopiedItem = copiedString
            DispatchQueue.main.async {
                if !self.clipboardHistory.contains(copiedString) {
                    self.clipboardHistory.insert(copiedString, at: 0)
                }
                if self.clipboardHistory.count > 50 {
                    self.clipboardHistory.removeLast()
                }
            }
        }
    }

    func pasteItem(_ item: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item, forType: .string)
    }
}

struct ClipboardView: View {
    @StateObject private var clipboardManager = ClipboardManager()

    var body: some View {
        VStack {
            List {
                ForEach(clipboardManager.clipboardHistory, id: \.self) { item in
                    HStack {
                        Text(item)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        Button("Copy") {
                            clipboardManager.pasteItem(item)
                        }
                    }
                }
                .onDelete(perform: deleteItem)
            }
            .frame(minWidth: 400, maxWidth: 400, minHeight: 500, maxHeight: 500)
        }
    }

    private func deleteItem(at offsets: IndexSet) {
        clipboardManager.clipboardHistory.remove(atOffsets: offsets)
    }
}

@main
struct ClipMgrApp: App {
    @State private var window: NSWindow?
    @StateObject private var clipboardManager = ClipboardManager()

    var body: some Scene {
        WindowGroup {
            ClipboardView()
                .frame(width: 400, height: 500)
                .onAppear {
                    setupWindow()
                }
        }
        .windowResizability(.contentSize)

        MenuBarExtra("Clipboard Manager", systemImage: "doc.on.clipboard") {
            ForEach(clipboardManager.clipboardHistory.prefix(5), id: \.self) { item in
                let truncatedItem = item.count > 30 ? String(item.prefix(27)) + "..." : item
                Button(truncatedItem) {
                    clipboardManager.pasteItem(item)
                }
            }
            Divider()
            Button("Show Clipboard Window") {
                toggleWindow()
            }
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }

    private func setupWindow() {
        if window == nil {
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )

            newWindow.contentView = NSHostingView(rootView: ClipboardView())
            newWindow.title = "Clipboard Manager"
            newWindow.isReleasedWhenClosed = false
            newWindow.center()
            window = newWindow
        }
    }

    private func toggleWindow() {
        if let window = window {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}
