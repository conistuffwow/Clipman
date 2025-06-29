//
//  ClipMenuView.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import Foundation
import SwiftUI

struct ClipMenuView: View {
    @StateObject private var monitor = ClipboardMonitor()
    @State private var isExpanded = false
    @State private var showDeleteConfirmation = false
    @State private var selectedClipToDelete: Clip? = nil
    @State private var sortNewestFirst = true
    @State private var searchQuery: String = ""
    @State private var redrawID = UUID()
    @State private var showSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Clipman")
                    .font(.headline)
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                        .padding()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        
                
                Picker("", selection: $sortNewestFirst) {
                    Text("newest-text").tag(true)
                    Text("oldest-text").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            .padding(.bottom, 4)
            
            if isExpanded {
                TextField("search-text", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 4)
                    .onChange(of: searchQuery) { _ in
                        redrawID = UUID()
                    }
            }
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
                                Text(clip.text)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(relativeDate(clip.createdAt))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
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
                    .id(redrawID)
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
        .padding()
        .frame(width: 400, height: isExpanded ? 500 : 310)
    }
    
    private func displayedClips() -> [Clip] {
        let filtered = monitor.clips.filter { clip in
            searchQuery.isEmpty || clip.text.localizedCaseInsensitiveContains(searchQuery)
        }
        
        let sorted = filtered.sorted {
            if $0.isFavourite != $1.isFavourite {
                return $0.isFavourite
            } else {
                return sortNewestFirst ? $0.createdAt > $1.createdAt : $0.createdAt < $1.createdAt
            }
        }
        return isExpanded ? sorted : Array(sorted.prefix(10))
    }
    
    func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    func isURL(_ text: String) -> Bool {
        text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://")
    }
}
