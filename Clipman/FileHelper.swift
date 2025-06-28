//
//  FileHelper.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import Foundation

func appSupportFileURL() -> URL {
    let fileManager = FileManager.default
    let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let clipManDir = appSupport.appendingPathComponent("ClipMan", isDirectory: true)
    
    if !fileManager.fileExists(atPath: clipManDir.path) {
        try? fileManager.createDirectory(at: clipManDir, withIntermediateDirectories: true)
    }
    
    return clipManDir.appendingPathComponent("clips.json")
}
