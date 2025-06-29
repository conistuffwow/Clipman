//
//  Settings.swift
//  Clipman
//
//  Created by Coni on 2025-06-29.
//

import Foundation
import SwiftUI
// this func hurts me
class Settingsa: ObservableObject {
    static let shared = Settingsa()
    
    @AppStorage("useICloud") var useICloud: Bool = false
    
    init() {} // singleton
}
