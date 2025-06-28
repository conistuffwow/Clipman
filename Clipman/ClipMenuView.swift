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
                                NSPasteboard.general.setString(clip, forType: .string)
                            }) {
                                Text(clip)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                monitor.delete(clip: clip)
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
    
    private func displayedClips() -> [String] {
        return isExpanded ? monitor.clips : Array(monitor.clips.prefix(5))
    }
}
