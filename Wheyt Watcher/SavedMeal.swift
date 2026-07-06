import Foundation
import SwiftData

@Model
final class SavedMeal {

    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var items: [MealItem] = []

    init(
        name: String,
        createdAt: Date = Date()
    ) {
        self.name = name
        self.createdAt = createdAt
    }
}//
//  SavedMeal.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

