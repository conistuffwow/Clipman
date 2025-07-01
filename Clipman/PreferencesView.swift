//
//  PreferencesView.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import Foundation
import SwiftUI
import ServiceManagement
import AppKit
import WebKit

struct SettingsView: View {
    @AppStorage("sortNewestFirst") var sortNewestFirst: Bool = true
    @AppStorage("maxClips") var maxClips: Int = 100
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("useICloud") private var useICloud = false
    @State private var showWipeConfirmation = false
    @StateObject private var monitor = ClipboardMonitor()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section  {
                HStack {
                    Button("closetxt") {
                        dismiss()
                    }
                }
            }
            Section {
                Toggle("launchlog", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        toggleLaunchAtLogin(enabled: newValue)}
            }
            
            Section {
                Button(role: .destructive) {
                    showWipeConfirmation = true
                } label: {
                    Label("wipeclips", systemImage: "trash")
                }
            }
            
            Section {
                Button("abttxt") {
                    NSApp.orderFrontStandardAboutPanel(nil)
                }
            }
            
            // Section {
             //   Toggle("useicloudtext", isOn: $useICloud)
              //      .help("helpicloud")
            // }
        }
        .alert("alertpref", isPresented: $showWipeConfirmation) {
            Button("delall", role: .destructive) {
                monitor.clips.removeAll()
                monitor.saveClips()
                monitor.loadClips()
            }
            Button("canceltx", role: .cancel) {}
            
            
        }
        .padding()
        .frame(width: 300, height: 200)
    }
    
    
}

func toggleLaunchAtLogin(enabled: Bool) {
    if #available(macOS 13.0, *) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to change setting")
        }
    }
}
