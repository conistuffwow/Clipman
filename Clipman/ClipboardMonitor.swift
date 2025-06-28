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
    private let fileURL = appSupportFileURL()
    
    init() {
        loadClips()
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
                        if self.clips.count > 100 {
                            self.clips.removeLast()
                        }
                        self.saveClips()
                    }
                }
            }
        }
    }
    
    private func saveClips() {
        do {
            let data = try JSONEncoder().encode(clips)
            try data.write(to: fileURL)
        } catch {
            print("Couldn't save clips: \(error)")
        }
    }
    
    private func loadClips() {
        do {
            let data = try Data(contentsOf: fileURL)
            let savedClips = try JSONDecoder().decode([String].self, from: data)
            self.clips = savedClips
        } catch {
            print("No saved clips...")
            self.clips = []
        }
    }
    
    func delete(clip: String) {
        if let index = clips.firstIndex(of: clip) {
            clips.remove(at: index)
            saveClips()
        }
    }
}
