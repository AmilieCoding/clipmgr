//
//  AppDelegate.swift
//  ClipMgr
//
//  Created by Ami on 28/02/2025.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var clipboardManager = ClipboardManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateMenu), userInfo: nil, repeats: true)
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Manager")
        }
        updateMenu()
    }

    @objc private func updateMenu() {
        let menu = NSMenu()

        // Show only the last 5 clipboard items
        let lastFiveItems = clipboardManager.clipboardHistory.suffix(5)
        for item in lastFiveItems.reversed() { // Reverse to keep the latest at the top
            let menuItem = NSMenuItem(title: item, action: #selector(copyToClipboard(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.representedObject = item
            menu.addItem(menuItem)
        }

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func copyToClipboard(_ sender: NSMenuItem) {
        if let text = sender.representedObject as? String {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
