//
//  ClipboardMonitor.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import Foundation
import AppKit

class ClipboardMonitor: ObservableObject {
    @Published var clips: [Clip] = []
    private var lastChangeCount = NSPasteboard.general.changeCount
    
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
                    if !self.clips.contains(where: { $0.text == string }) {
                        let newClip = Clip(text: string)
                        self.clips.insert(newClip, at: 0)
                        if self.clips.count > 100 {
                            self.clips.removeLast()
                        }
                        self.saveClips()
                    }
                }
            }
        }
    }
    
    func saveClips() {
        let fileURL = clipStorageURL()
        do {
            let data = try JSONEncoder().encode(clips)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Couldn't save clips: \(error)")
        }
    }
    
    func loadClips() {
        let fileURL = clipStorageURL()
        do {
            let data = try Data(contentsOf: fileURL)
            let savedClips = try JSONDecoder().decode([Clip].self, from: data)
            self.clips = savedClips
        } catch {
            print("No saved clips...")
            self.clips = []
        }
    }
    
    func delete(clip: Clip) {
        if let index = clips.firstIndex(of: clip) {
            clips.remove(at: index)
            saveClips()
        }
    }
    
    func toggleFavourite(clip: Clip) {
        if let index = clips.firstIndex(of: clip) {
            clips[index].isFavourite.toggle()
            saveClips()
        }
    }
    
    func togglePinned(clip: Clip) {
        if let index = clips.firstIndex(where: { $0.id == clip.id }) {
            clips[index].isPinned.toggle()
            saveClips()
        }
    }
    
    func iCloudDirectory() -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents/Clipman", isDirectory: true)
    }
    
    func clipStorageURL() -> URL {
        let fileManager = FileManager.default

        if Settingsa.shared.useICloud,
           let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: nil)?
                .appendingPathComponent("Documents/Clipman", isDirectory: true) {
            try? fileManager.createDirectory(at: iCloudURL, withIntermediateDirectories: true)
            return iCloudURL.appendingPathComponent("clips.json")
        } else {
            let localURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                .appendingPathComponent("Clipman", isDirectory: true)
            try? fileManager.createDirectory(at: localURL, withIntermediateDirectories: true)
            return localURL.appendingPathComponent("clips.json")
        }
    }
}

