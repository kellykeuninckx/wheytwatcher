import SwiftUI
import SwiftData

struct LogbookEntryRow: View {

    let entry: FoodLogEntry
    let isFavorite: Bool

    let isSelecting: Bool
    let isSelected: Bool

    let toggleFavorite: () -> Void
    let toggleSelection: () -> Void


    var body: some View {

        HStack {

            if isSelecting {

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(Color.wwTeal)

            }

            VStack(alignment: .leading, spacing: 2) {

                Text(entry.name)
                    .font(.headline)

                Text("\(entry.grams.roundedInt) g • \(entry.calories.roundedInt) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            }

            Spacer()

            Button(action: toggleFavorite) {

                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? Color.wwCoral : .secondary)

            }
            .buttonStyle(.plain)

        }
        
        .contentShape(Rectangle())
        .onTapGesture {

            guard isSelecting else { return }

            toggleSelection()

        }

    }

}//
//  LogbookEntryRow.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

