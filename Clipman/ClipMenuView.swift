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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Clips")
                .font(.headline)
            
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
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                monitor.toggleFavourite(clip: clip)
                            }) {
                                Image(systemName: clip.isFavourite ? "star.fill" : "star")
                                    .foregroundColor(clip.isFavourite ? .yellow : .gray)
                                    .help(clip.isFavourite ? "Unfavourite" : "Favourite")
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
                                    .help("Delete Clip")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
            }
            
            .alert("Are you SURE you want to delete this clip?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let clip = selectedClipToDelete {
                        monitor.delete(clip: clip)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            
            Divider()
            
            Button(isExpanded ? "Collapse" : "Expand") {
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
        return isExpanded ? monitor.clips : Array(monitor.clips.prefix(5))
    }
}
