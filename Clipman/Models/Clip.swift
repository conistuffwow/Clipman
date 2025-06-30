//
//  Clip.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import Foundation
import SwiftUI

struct Clip: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let text: String
    var isFavourite: Bool
    let createdAt: Date
    var imageFilename: String?
    var isPinned: Bool = false
    var group: ClipGroup = .red
    
    init(id: UUID = UUID(), text: String, isFavourite: Bool = false, createdAt: Date = Date(), imageFilename: String? = nil, isPinned: Bool = false, group: ClipGroup = .none) {
        self.id = id
        self.text = text
        self.isFavourite = isFavourite
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.group = group
    }
    
}

enum ClipGroup: String, Codable, CaseIterable, Identifiable {
    case none
    case red
    case blue
    case green
    case yellow
    case purple

    var id: String { rawValue }

    var localizationKey: String {
            switch self {
            case .none: return "clpg.none"
            case .red: return "clpg.red"
            case .blue: return "clpg.blue"
            case .green: return "clpg.green"
            case .yellow: return "clpg.yellow"
            case .purple: return "clpg.purple"
            }
        }

        var displayName: String {
            NSLocalizedString(localizationKey, comment: "")
        }

        var displayNameKey: LocalizedStringKey {
            LocalizedStringKey(localizationKey)
        }

        var color: Color {
            switch self {
            case .none: return .clear
            case .red: return .red
            case .blue: return .blue
            case .green: return .green
            case .yellow: return .yellow
            case .purple: return .purple
            }
        }
    }
