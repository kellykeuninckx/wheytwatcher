import SwiftUI
import SwiftData

struct SaveMealView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var mealName = ""

    var body: some View {

        NavigationStack {

            Form {

                Section("Naam") {

                    TextField("Bijvoorbeeld: Enchiladas", text: $mealName)

                }

            }
            .navigationTitle("Maaltijd opslaan")

            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button("Annuleren") {
                        dismiss()
                    }

                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Opslaan") {

                        let meal = SavedMeal(name: mealName)

                        modelContext.insert(meal)

                        try? modelContext.save()

                        dismiss()

                    }
                    .disabled(mealName.trimmingCharacters(in: .whitespaces).isEmpty)

                }

            }

        }

    }

}//
//  SavedMealView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

