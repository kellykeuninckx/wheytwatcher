//
//  Item.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 03/07/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
