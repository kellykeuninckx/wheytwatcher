import Foundation

struct LocalFoodItem: Identifiable {
    let id = UUID()
    let name: String
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let fiberPer100g: Double
}

/// Vaste lijst met veelgebruikte basisproducten (fruit, groente, zuivel, granen, vlees/vis, noten,
/// peulvruchten) — deze hebben geen barcode, dus Open Food Facts vindt ze zelden goed. Deze lijst
/// wordt eerst doorzocht, vóór er een netwerkaanroep gebeurt.
enum LocalFoodDatabase {

    static let items: [LocalFoodItem] = [
        // Fruit
        LocalFoodItem(name: "Banaan", caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23, fatPer100g: 0.3, fiberPer100g: 2.6),
        LocalFoodItem(name: "Appel", caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14, fatPer100g: 0.2, fiberPer100g: 2.4),
        LocalFoodItem(name: "Sinaasappel", caloriesPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 12, fatPer100g: 0.1, fiberPer100g: 2.4),
        LocalFoodItem(name: "Peer", caloriesPer100g: 57, proteinPer100g: 0.4, carbsPer100g: 15, fatPer100g: 0.1, fiberPer100g: 3.1),
        LocalFoodItem(name: "Druiven", caloriesPer100g: 69, proteinPer100g: 0.7, carbsPer100g: 18, fatPer100g: 0.2, fiberPer100g: 0.9),
        LocalFoodItem(name: "Aardbeien", caloriesPer100g: 32, proteinPer100g: 0.7, carbsPer100g: 8, fatPer100g: 0.3, fiberPer100g: 2.0),
        LocalFoodItem(name: "Blauwe bessen", caloriesPer100g: 57, proteinPer100g: 0.7, carbsPer100g: 14, fatPer100g: 0.3, fiberPer100g: 2.4),
        LocalFoodItem(name: "Mango", caloriesPer100g: 60, proteinPer100g: 0.8, carbsPer100g: 15, fatPer100g: 0.4, fiberPer100g: 1.6),
        LocalFoodItem(name: "Ananas", caloriesPer100g: 50, proteinPer100g: 0.5, carbsPer100g: 13, fatPer100g: 0.1, fiberPer100g: 1.4),
        LocalFoodItem(name: "Avocado", caloriesPer100g: 160, proteinPer100g: 2.0, carbsPer100g: 9, fatPer100g: 15, fiberPer100g: 7.0),

        // Groente
        LocalFoodItem(name: "Broccoli (gekookt)", caloriesPer100g: 35, proteinPer100g: 2.4, carbsPer100g: 7, fatPer100g: 0.4, fiberPer100g: 3.3),
        LocalFoodItem(name: "Wortel", caloriesPer100g: 41, proteinPer100g: 0.9, carbsPer100g: 10, fatPer100g: 0.2, fiberPer100g: 2.8),
        LocalFoodItem(name: "Komkommer", caloriesPer100g: 15, proteinPer100g: 0.7, carbsPer100g: 3.6, fatPer100g: 0.1, fiberPer100g: 0.5),
        LocalFoodItem(name: "Tomaat", caloriesPer100g: 18, proteinPer100g: 0.9, carbsPer100g: 3.9, fatPer100g: 0.2, fiberPer100g: 1.2),
        LocalFoodItem(name: "Paprika", caloriesPer100g: 31, proteinPer100g: 1.0, carbsPer100g: 6, fatPer100g: 0.3, fiberPer100g: 2.1),
        LocalFoodItem(name: "Spinazie (rauw)", caloriesPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6, fatPer100g: 0.4, fiberPer100g: 2.2),
        LocalFoodItem(name: "Ui", caloriesPer100g: 40, proteinPer100g: 1.1, carbsPer100g: 9, fatPer100g: 0.1, fiberPer100g: 1.7),
        LocalFoodItem(name: "Aardappel (gekookt)", caloriesPer100g: 87, proteinPer100g: 1.9, carbsPer100g: 20, fatPer100g: 0.1, fiberPer100g: 1.8),
        LocalFoodItem(name: "Zoete aardappel (gekookt)", caloriesPer100g: 90, proteinPer100g: 2.0, carbsPer100g: 21, fatPer100g: 0.2, fiberPer100g: 3.0),
        LocalFoodItem(name: "Sla", caloriesPer100g: 15, proteinPer100g: 1.4, carbsPer100g: 2.9, fatPer100g: 0.2, fiberPer100g: 1.3),

        // Zuivel & eiwit
        LocalFoodItem(name: "Ei (gekookt)", caloriesPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatPer100g: 11, fiberPer100g: 0),
        LocalFoodItem(name: "Magere kwark", caloriesPer100g: 60, proteinPer100g: 12, carbsPer100g: 4, fatPer100g: 0.2, fiberPer100g: 0),
        LocalFoodItem(name: "Griekse yoghurt", caloriesPer100g: 97, proteinPer100g: 9, carbsPer100g: 4, fatPer100g: 5, fiberPer100g: 0),
        LocalFoodItem(name: "Melk (halfvol)", caloriesPer100g: 46, proteinPer100g: 3.4, carbsPer100g: 4.7, fatPer100g: 1.5, fiberPer100g: 0),
        LocalFoodItem(name: "Kipfilet (gegrild)", caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, fiberPer100g: 0),
        LocalFoodItem(name: "Zalm (gegrild)", caloriesPer100g: 208, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 13, fiberPer100g: 0),
        LocalFoodItem(name: "Tonijn (in water)", caloriesPer100g: 116, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 1, fiberPer100g: 0),
        LocalFoodItem(name: "Tofu", caloriesPer100g: 76, proteinPer100g: 8, carbsPer100g: 1.9, fatPer100g: 4.8, fiberPer100g: 0.3),

        // Granen & koolhydraten
        LocalFoodItem(name: "Havermout (droog)", caloriesPer100g: 389, proteinPer100g: 17, carbsPer100g: 66, fatPer100g: 7, fiberPer100g: 10),
        LocalFoodItem(name: "Witte rijst (gekookt)", caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28, fatPer100g: 0.3, fiberPer100g: 0.4),
        LocalFoodItem(name: "Bruine rijst (gekookt)", caloriesPer100g: 123, proteinPer100g: 2.6, carbsPer100g: 26, fatPer100g: 1.0, fiberPer100g: 1.8),
        LocalFoodItem(name: "Volkoren brood", caloriesPer100g: 247, proteinPer100g: 13, carbsPer100g: 41, fatPer100g: 3.4, fiberPer100g: 7),
        LocalFoodItem(name: "Pasta (gekookt)", caloriesPer100g: 131, proteinPer100g: 5, carbsPer100g: 25, fatPer100g: 1.1, fiberPer100g: 1.8),
        LocalFoodItem(name: "Quinoa (gekookt)", caloriesPer100g: 120, proteinPer100g: 4.4, carbsPer100g: 21, fatPer100g: 1.9, fiberPer100g: 2.8),

        // Noten & vetten
        LocalFoodItem(name: "Amandelen", caloriesPer100g: 579, proteinPer100g: 21, carbsPer100g: 22, fatPer100g: 50, fiberPer100g: 12.5),
        LocalFoodItem(name: "Walnoten", caloriesPer100g: 654, proteinPer100g: 15, carbsPer100g: 14, fatPer100g: 65, fiberPer100g: 6.7),
        LocalFoodItem(name: "Pindakaas", caloriesPer100g: 588, proteinPer100g: 25, carbsPer100g: 20, fatPer100g: 50, fiberPer100g: 6),
        LocalFoodItem(name: "Olijfolie", caloriesPer100g: 884, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 100, fiberPer100g: 0),

        // Peulvruchten
        LocalFoodItem(name: "Linzen (gekookt)", caloriesPer100g: 116, proteinPer100g: 9, carbsPer100g: 20, fatPer100g: 0.4, fiberPer100g: 7.9),
        LocalFoodItem(name: "Kikkererwten (gekookt)", caloriesPer100g: 164, proteinPer100g: 9, carbsPer100g: 27, fatPer100g: 2.6, fiberPer100g: 7.6),
        LocalFoodItem(name: "Zwarte bonen (gekookt)", caloriesPer100g: 132, proteinPer100g: 8.9, carbsPer100g: 24, fatPer100g: 0.5, fiberPer100g: 8.7)
    ]

    /// Zoekt basisproducten op naam, accent- en hoofdletterongevoelig.
    static func search(_ query: String) -> [LocalFoodItem] {
        let normalized = query.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        guard !normalized.isEmpty else { return [] }

        return items.filter {
            $0.name.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(normalized)
        }
    }

}//
//  LocalFoodDatabase.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 09/07/2026.
//

