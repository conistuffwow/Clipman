//
//  ClipmanApp.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import SwiftUI

@main
struct ClipmanApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
                    }

    }
    
    
    
    func promptUpdate(latestVersion: String) {
        let alert = NSAlert()
        alert.messageText = "updateavtxt"
        alert.informativeText = "Clipman \(latestVersion) available."
        alert.addButton(withTitle: "updtxt")
        alert.addButton(withTitle: "canceltx")
        
        if alert.runModal() == .alertFirstButtonReturn {
            downloadAndInstallUpd()
        }
    }
    
    func downloadAndInstallUpd() {
        let task = URLSession.shared.downloadTask(with: updateDownloadURL!) { tempURL, _, _ in
            guard let tempURL = tempURL else {
                showUpdateError("failtxt")
                return
            }
            
            let unzipDir = FileManager.default.temporaryDirectory.appendingPathComponent("ClipmanUpdate")
            try? FileManager.default.createDirectory(at: unzipDir, withIntermediateDirectories: true)
            
            let process = Process()
            process.launchPath = "/usr/bin/unzip"
            process.arguments = [tempURL.path, "-d", unzipDir.path]
            process.launch()
            process.waitUntilExit()
            
            let newAppPath = unzipDir.appendingPathComponent("Clipman.app")
            
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "updinst"
                alert.informativeText = "updinstinfo"
                alert.runModal()
                
                let currentAppPath = Bundle.main.bundlePath
                
                let task = Process()
                task.launchPath = "/bin/sh"
                task.arguments = [
                    "-c",
                    "sleep 1; rm -rf \"\(currentAppPath)\"; cp -R \"\(newAppPath.path)\" \"\(currentAppPath)\"; open \"\(currentAppPath)\""
                
                ]
                task.launch()
                
                NSApp.terminate(nil)
            }
        }
        task.resume()
    }
    func showUpdateError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "upderr"
        alert.informativeText = message
        alert.runModal()
    }
    
    func showNoUpdateNeeded() {
        let alert = NSAlert()
        alert.messageText = "uptodate"
        alert.runModal()
    }


}
