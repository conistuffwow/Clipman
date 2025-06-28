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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Clips")
                .font(.headline)
                .padding(.bottom, 5)
            ForEach(monitor.clips.prefix(5), id: \.self) { clip in
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(clip, forType: .string)
                }) {
                    Text(clip)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .frame(width: 200)
    }
}
