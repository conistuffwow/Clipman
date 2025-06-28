//
//  PreferencesView.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage("sortNewestFirst") var sortNewestFirst: Bool = true
    @AppStorage("maxClips") var maxClips: Int = 100
    
    var body: some View {
        Form {
            
            Section(header: Text("")) {
                Stepper(value: $maxClips, in: 10...1000, step: 10) {
                    Text("Max Clips: \(maxClips)")
                }
            }
        }
        .padding()
        .frame(width: 250, height: 100)
    }
}
