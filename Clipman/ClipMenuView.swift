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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Clips")
                .font(.headline)
        
                
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
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(clip.text, forType: .string)
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
                                    .foregroundColor(clip.isFavourite ? .yellow : .gray)
                                    .help(clip.isFavourite ? "unfavtxt" : "favtxt")
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
        .frame(width: 300, height: isExpanded ? 400 : 200)
    }
    
    private func displayedClips() -> [Clip] {
        let filtered = monitor.clips.filter { clip in
            searchQuery.isEmpty || clip.text.localizedCaseInsensitiveContains(searchQuery)
        }
        
        let sorted = sortNewestFirst
        ? filtered.sorted { $0.createdAt > $1.createdAt }
        : filtered.sorted { $0.createdAt < $1.createdAt }
        return isExpanded ? sorted : Array(sorted.prefix(5))
    }
    
    func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
