//
//  ClipboardMonitor.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import Foundation
import AppKit

class ClipboardMonitor: ObservableObject {
    @Published var clips: [String] = []
    private var lastChangeCount = NSPasteboard.general.changeCount
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()}
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            if let string = pasteboard.string(forType: .string) {
                DispatchQueue.main.async {
                    if !self.clips.contains(string) {
                        self.clips.insert(string, at: 0)
                        if self.clips.count > 50 {
                            self.clips.removeLast()
                        }
                    }
                }
            }
        }
    }
}
