//
//  ClipMenuView.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import Foundation
import SwiftUI
import AppKit

struct ClipMenuView: View {
    @StateObject private var monitor = ClipboardMonitor()
    @State private var isExpanded = false
    @State private var showDeleteConfirmation = false
    @State private var selectedClipToDelete: Clip? = nil
    @State private var sortNewestFirst = true
    @State private var searchQuery: String = ""
    @State private var redrawID = UUID()
    @State private var showSettings = false
    @State private var showUpdCheck = false
    @State private var updateURL = URL(string: "https://github.com/conistuffwow/clipman/releases/latest/download/clipman.zip")
    @State private var selectedGroup: ClipGroup? = ClipGroup.none
    let currentVersion = "2.0.0b"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Clipman")
                    .font(.headline)
                
                Spacer()
                
                Picker("", selection: $sortNewestFirst) {
                    Text("newest-text").tag(true)
                    Text("oldest-text").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 160)
                .padding(.trailing, 8)
                Spacer()
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                        .padding(4)
                        .help("Settings")
                }
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
            if isExpanded {
                TextField("search-text", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 4)
                    .onChange(of: searchQuery) { _ in
                        redrawID = UUID()
                    }
            }
                
            
            Picker("", selection: $selectedGroup) {
                ForEach(ClipGroup.allCases) { group in
                    Text(group.displayName).tag(Optional(group))
                }
                Text("clpg.all").tag(nil as ClipGroup?)
            }
            .pickerStyle(SegmentedPickerStyle())
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            
            
            
        
            
            .padding(.bottom, 4)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(displayedClips(), id: \.self) { clip in
                        HStack {
                            Button(action: {
                                if isURL(clip.text) {
                                    if let url = URL(string: clip.text) {
                                        NSWorkspace.shared.open(url)
                                    }
                                } else {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(clip.text, forType: .string)
                                }
                            }) {
                                HStack {
                                    Image(systemName: iconName(for: clip.text))
                                        .foregroundColor(.accentColor)
                                        
                                    Text(clip.text)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(relativeDate(clip.createdAt))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help(clip.text)
                            
                            Button(action: {
                                monitor.toggleFavourite(clip: clip)
                            }) {
                                Image(systemName: clip.isFavourite ? "star.fill" : "star")
                                    .foregroundColor(clip.isFavourite ? .accentColor : .gray)
                                    .help(clip.isFavourite ? "unfavtxt" : "favtxt")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            if isURL(clip.text) {
                                Button(action: {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(clip.text, forType: .string)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.accentColor)
                                        
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            
                            Menu {
                                ForEach(ClipGroup.allCases) { group in
                                    Button(group.displayName) {
                                        monitor.setGroup(for: clip, to: group)
                                    }
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(
                                            (clip.group ?? .none) == .none
                                                ? Color.gray.opacity(0.2)
                                                : (clip.group ?? .none).color.opacity(1)
                                        )
                                        .frame(width: 24, height: 24)

                                    Image(systemName: "folder")
                                        .foregroundColor(
                                            clip.group.color
                                        )
                                        .font(.system(size: 12, weight: .medium))
                            
                                    
                                    
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            Button(action: {
                                if clip.isFavourite {
                                    selectedClipToDelete = clip
                                    showDeleteConfirmation = true
                                } else {
                                    monitor.delete(clip: clip)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .help("deltx")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        
                            

                        }
                    }
                    .id(sortNewestFirst)
                }
            }
            
            .alert("alertinsidetxt", isPresented: $showDeleteConfirmation) {
                Button("deltx", role: .destructive) {
                    if let clip = selectedClipToDelete {
                        monitor.delete(clip: clip)
                    }
                }
                Button("canceltx", role: .cancel) { }
            }
            
            Divider()
            
            Button(isExpanded ? "collapsetxt" : "expandtxr") {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 4)
        }
        .onAppear {
            checkForUpdates()
        }
        .alert("updavailabletxt", isPresented: $showUpdCheck) {
            Button("dltxt") {
                NSWorkspace.shared.open(URL(string: "https://github.com/conistuffwow/clipman/releases/latest/download/clipman.zip")!)
            }
            Button("canceltx", role: .cancel) {}
        }
        .padding()
        .frame(width: 470, height: isExpanded ? 500 : 310)
    }
    
    private func checkForUpdates() {
        guard let url = URL(string: "https://raw.githubusercontent.com/conistuffwow/CSUS/refs/heads/main/clipman/upd.txt") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
                guard error == nil,
                      let data = data,
                      let remoteVersion = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            else { return }
            
            if remoteVersion != currentVersion {
                DispatchQueue.main.async {
                    showUpdCheck = true
                }
            }
                        
        }.resume()
    }
    
    
    
    private func displayedClips() -> [Clip] {
        let filtered = monitor.clips.filter { clip in
            let matchesSearch = searchQuery.isEmpty || clip.text.localizedCaseInsensitiveContains(searchQuery)
            let matchesGroup = selectedGroup == nil || clip.group == selectedGroup!
            return matchesSearch && matchesGroup
        }

        let sorted = sortNewestFirst
            ? filtered.sorted { $0.createdAt > $1.createdAt }
            : filtered.sorted { $0.createdAt < $1.createdAt }

        return isExpanded ? sorted : Array(sorted.prefix(7))
    }
    func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    func isURL(_ text: String) -> Bool {
        text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://")
    }

    func iconName(for text: String) -> String {
        if isURL(text) {
            return "globe"
        } else {
            return "doc.text"
        }
    }
    


    
    
}
