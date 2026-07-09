import SwiftUI
import SwiftData

struct FoodSearchView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var localProducts: [FoodProduct]

    @State private var query = ""
    @State private var results: [OpenFoodFactsLookupResult] = []
    @State private var localResults: [LocalFoodItem] = []
    @State private var isSearching = false
    @State private var hasSearchedOnce = false
    @State private var searchTask: Task<Void, Never>?
    @State private var selectedProduct: FoodProduct?

    var body: some View {
        NavigationStack {
            ZStack {

                DumbbellPatternBackground()

                if query.trimmingCharacters(in: .whitespaces).isEmpty {

                    WWPlaceholderCard(
                        icon: "magnifyingglass",
                        color: .wwTeal,
                        title: "Zoek een product",
                        message: "Typ een naam (bv. 'banaan' of 'kwark') en druk op zoeken."
                    )
                    .padding()

                } else if !hasSearchedOnce && !isSearching {

                    WWPlaceholderCard(
                        icon: "arrow.turn.down.left",
                        color: .wwTeal,
                        title: "Klaar om te zoeken",
                        message: "Druk op zoeken op je toetsenbord om te starten."
                    )
                    .padding()

                } else if results.isEmpty && localResults.isEmpty && !isSearching && hasSearchedOnce {

                    WWPlaceholderCard(
                        icon: "questionmark.circle",
                        color: .wwOrange,
                        title: "Niets gevonden",
                        message: "Probeer een andere zoekterm."
                    )
                    .padding()

                } else {

                    List {

                        if !localResults.isEmpty {

                            Text("Basisproducten")
                                .font(.caption.bold())
                                .foregroundStyle(Color.wwSecondaryText)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 2, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)

                            ForEach(localResults) { item in
                                Button {
                                    select(item)
                                } label: {
                                    HStack {

                                        Text(item.name)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(Color.wwDarkAccent)

                                        Spacer()

                                        Text("\(item.caloriesPer100g.roundedInt) kcal/100g")
                                            .font(.caption)
                                            .foregroundStyle(Color.wwSecondaryText)

                                    }
                                }
                                .buttonStyle(.plain)
                                .cardRow()
                            }

                        }

                        if !results.isEmpty {

                            Text("Merkproducten")
                                .font(.caption.bold())
                                .foregroundStyle(Color.wwSecondaryText)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 2, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)

                            ForEach(Array(results.enumerated()), id: \.offset) { _, result in
                                Button {
                                    select(result)
                                } label: {
                                    HStack {

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(result.name)
                                                .font(.subheadline.bold())
                                                .foregroundStyle(Color.wwDarkAccent)

                                            if let brand = result.brand, !brand.trimmingCharacters(in: .whitespaces).isEmpty {
                                                Text(brand)
                                                    .font(.caption)
                                                    .foregroundStyle(Color.wwSecondaryText)
                                            }
                                        }

                                        Spacer()

                                        Text("\(result.caloriesPer100g.roundedInt) kcal/100g")
                                            .font(.caption)
                                            .foregroundStyle(Color.wwSecondaryText)

                                    }
                                }
                                .buttonStyle(.plain)
                                .cardRow()
                            }

                        }

                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                }

                if isSearching {
                    ProgressView()
                        .tint(Color.wwTeal)
                }

            }
            .searchable(text: $query, prompt: "Zoek een product")
            .onSubmit(of: .search) {
                let trimmed = query.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else {
                    results = []
                    localResults = []
                    hasSearchedOnce = false
                    return
                }

                localResults = LocalFoodDatabase.search(trimmed)

                searchTask?.cancel()
                searchTask = Task {
                    await performSearch(query: trimmed)
                }
            }
            .onChange(of: query) {
                searchTask?.cancel()
                results = []
                localResults = []
                hasSearchedOnce = false
            }
            .navigationTitle("Zoek product")
            .navigationBarTitleDisplayMode(.inline)
            .tint(Color.wwTeal)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedProduct) { product in
                FoodProductQuickAddView(product: product) {
                    dismiss()
                }
            }

        }
    }

    private func performSearch(query: String) async {
        isSearching = true

        do {
            let searchResults = try await OpenFoodFactsService.searchProducts(query: query)
            await MainActor.run {
                results = searchResults
                isSearching = false
                hasSearchedOnce = true
            }
        } catch {
            await MainActor.run {
                results = []
                isSearching = false
                hasSearchedOnce = true
            }
        }
    }

    /// Basisproduct uit de lokale lijst: géén barcode, dus niet opgeslagen in de database —
    /// puur een tijdelijk object om de hoeveelheid/maaltijd-kiezer te vullen.
    private func select(_ item: LocalFoodItem) {
        selectedProduct = FoodProduct(
            name: item.name,
            caloriesPer100g: item.caloriesPer100g,
            proteinPer100g: item.proteinPer100g,
            carbsPer100g: item.carbsPer100g,
            fatPer100g: item.fatPer100g,
            fiberPer100g: item.fiberPer100g
        )
    }

    private func select(_ result: OpenFoodFactsLookupResult) {

        if let barcode = result.barcode,
           let existing = localProducts.first(where: { $0.barcode == barcode }) {
            selectedProduct = existing
            return
        }

        let product = FoodProduct(
            name: result.name,
            brand: result.brand,
            barcode: result.barcode,
            caloriesPer100g: result.caloriesPer100g,
            proteinPer100g: result.proteinPer100g,
            carbsPer100g: result.carbsPer100g,
            fatPer100g: result.fatPer100g,
            fiberPer100g: result.fiberPer100g
        )

        modelContext.insert(product)
        try? modelContext.save()

        selectedProduct = product
    }

}

private extension View {
    func cardRow() -> some View {
        self
            .padding(14)
            .background(Color.wwCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}
