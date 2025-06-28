//
//  Clip.swift
//  Clipman
//
//  Created by Coni on 2025-06-28.
//

import Foundation

struct Clip: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let text: String
    var isFavourite: Bool
    
    init(id: UUID = UUID(), text: String, isFavourite: Bool = false) {
        self.id = id
        self.text = text
        self.isFavourite = isFavourite
    }
}
