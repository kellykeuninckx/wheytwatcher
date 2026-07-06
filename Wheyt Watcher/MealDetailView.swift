import SwiftUI
import SwiftData

struct MealDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let meal: SavedMeal

    private var totalCalories: Int {
        Int(meal.items.reduce(0) { $0 + $1.calories }.rounded())
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

                        Text("Ingrediënten")
                            .font(.headline)
                            .foregroundStyle(Color.wwDarkAccent)

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

                            }

                        }

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .wwCard()

                    Button {

                        for item in meal.items {

                            let entry = FoodLogEntry(
                                date: Date(),
                                mealCategory: .lunch,
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

    }

}
