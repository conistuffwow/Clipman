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
    let createdAt: Date
    var imageFilename: String?
    var isImage: Bool {
        imageFilename != nil
    }
    
    init(id: UUID = UUID(), text: String, isFavourite: Bool = false, createdAt: Date = Date(), imageFilename: String? = nil) {
        self.id = id
        self.text = text
        self.isFavourite = isFavourite
        self.createdAt = createdAt
        self.imageFilename = imageFilename
    }
    
}
