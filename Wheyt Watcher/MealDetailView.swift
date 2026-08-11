import SwiftUI
import SwiftData

struct MealDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let meal: SavedMeal

    @State private var selectedCategory: MealCategory = .lunch
    @State private var showingSearch = false

    private var totalCalories: Int {
        Int(meal.items.reduce(0) { $0 + $1.calories }.rounded())
    }

    /// Voegt een ingrediënt toe dat via de productzoeker (in "ingrediënt-modus")
    /// is gekozen: waarden worden geschaald naar de gekozen hoeveelheid.
    private func addIngredient(_ product: FoodProduct, grams: Double) {
        let factor = grams / 100.0
        let item = MealItem(
            name: product.name,
            grams: grams,
            calories: product.caloriesPer100g * factor,
            proteinGrams: product.proteinPer100g * factor,
            carbsGrams: product.carbsPer100g * factor,
            fatGrams: product.fatPer100g * factor,
            fiberGrams: product.fiberPer100g * factor
        )
        meal.items.append(item)
        try? modelContext.save()
    }

    private func deleteItem(_ item: MealItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }

    var body: some View {

        WWScreen(accent: .wwOrange) {

            ScrollView {

                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 8) {

                        Text(meal.name)
                            .font(.title2.bold())
                            .foregroundStyle(Color.wwDarkAccent)

                        Text("\(meal.items.count) ingrediënten")
                            .foregroundStyle(Color.wwSecondaryText)

                        Text("\(totalCalories) kcal")
                            .font(.headline)
                            .foregroundStyle(Color.wwOrange)

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .wwCard()

                    VStack(alignment: .leading, spacing: 12) {

                        HStack {

                            Text("Ingrediënten")
                                .font(.headline)
                                .foregroundStyle(Color.wwDarkAccent)

                            Spacer()

                            Button {
                                showingSearch = true
                            } label: {
                                Label("Toevoegen", systemImage: "plus")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.wwOrange)
                            }

                        }

                        if meal.items.isEmpty {

                            Text("Nog geen ingrediënten. Tik op \"Toevoegen\" om er een toe te voegen.")
                                .font(.subheadline)
                                .foregroundStyle(Color.wwSecondaryText)

                        }

                        ForEach(meal.items) { item in

                            HStack {

                                VStack(alignment: .leading, spacing: 2) {

                                    Text(item.name)
                                        .foregroundStyle(Color.wwDarkAccent)

                                    Text("\(item.calories.roundedInt) kcal")
                                        .font(.caption)
                                        .foregroundStyle(Color.wwSecondaryText)

                                }

                                Spacer()

                                Text("\(item.grams.roundedInt) g")
                                    .foregroundStyle(Color.wwSecondaryText)

                                Button {
                                    deleteItem(item)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color.wwSecondaryText)
                                }
                                .buttonStyle(.plain)

                            }

                        }

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .wwCard()

                    HStack {

                        Text("Eetmoment")
                            .foregroundStyle(Color.wwDarkAccent)

                        Spacer()

                        Menu {
                            ForEach(MealCategory.allCases) { category in
                                Button(category.rawValue) {
                                    selectedCategory = category
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedCategory.rawValue)
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.wwOrange)
                        }

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .wwCard()

                    Button {

                        for item in meal.items {

                            let entry = FoodLogEntry(
                                date: Date(),
                                mealCategory: selectedCategory,
                                name: item.name,
                                grams: item.grams,
                                calories: item.calories,
                                proteinGrams: item.proteinGrams,
                                carbsGrams: item.carbsGrams,
                                fatGrams: item.fatGrams,
                                fiberGrams: item.fiberGrams
                            )

                            modelContext.insert(entry)

                        }

                        try? modelContext.save()
                        dismiss()

                    } label: {

                        Label("Voeg toe aan vandaag",
                              systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)

                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.wwOrange)

                }
                .padding(.vertical)

            }

        }
        .navigationTitle(meal.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSearch) {
            FoodSearchView { product, grams in
                addIngredient(product, grams: grams)
            }
        }

    }

}
