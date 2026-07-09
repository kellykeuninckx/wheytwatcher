import Foundation

struct OpenFoodFactsLookupResult {
    let name: String
    let brand: String?
    let barcode: String?
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let fiberPer100g: Double
}

enum OpenFoodFactsError: Error {
    case invalidURL
    case notFound
}

enum OpenFoodFactsService {

    /// Zoekt een product op via barcode bij Open Food Facts (gratis, geen API-key nodig).
    /// Geeft nil terug als het product niet bestaat in hun database (geen fout, gewoon "niet gevonden").
    static func lookup(barcode: String) async throws -> OpenFoodFactsLookupResult? {
        guard let url = URL(
            string: "https://nl.openfoodfacts.org/api/v2/product/\(barcode).json?fields=product_name,brands,nutriments"
        ) else {
            throw OpenFoodFactsError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)

        guard decoded.status == 1,
              let product = decoded.product,
              let name = product.productName,
              !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }

        let nutriments = product.nutriments

        return OpenFoodFactsLookupResult(
            name: name,
            brand: product.brands,
            barcode: barcode,
            caloriesPer100g: nutriments?.energyKcal100g ?? 0,
            proteinPer100g: nutriments?.proteins100g ?? 0,
            carbsPer100g: nutriments?.carbohydrates100g ?? 0,
            fatPer100g: nutriments?.fat100g ?? 0,
            fiberPer100g: nutriments?.fiber100g ?? 0
        )
    }

    /// Zoekt producten op naam bij Open Food Facts. Geeft een lege lijst terug als er niks matcht.
    static func searchProducts(query: String) async throws -> [OpenFoodFactsLookupResult] {
        var components = URLComponents(string: "https://nl.openfoodfacts.org/cgi/search.pl")
        components?.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "20"),
            URLQueryItem(name: "fields", value: "product_name,brands,code,nutriments")
        ]

        guard let url = components?.url else {
            throw OpenFoodFactsError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(OpenFoodFactsSearchResponse.self, from: data)

        return decoded.products.compactMap { product in
            guard let name = product.productName,
                  !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                return nil
            }

            let nutriments = product.nutriments

            return OpenFoodFactsLookupResult(
                name: name,
                brand: product.brands,
                barcode: product.code,
                caloriesPer100g: nutriments?.energyKcal100g ?? 0,
                proteinPer100g: nutriments?.proteins100g ?? 0,
                carbsPer100g: nutriments?.carbohydrates100g ?? 0,
                fatPer100g: nutriments?.fat100g ?? 0,
                fiberPer100g: nutriments?.fiber100g ?? 0
            )
        }
    }
}

// MARK: - Response-modellen (matchen de velden die we opvragen)

private struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: OpenFoodFactsProduct?
}

private struct OpenFoodFactsSearchResponse: Codable {
    let products: [OpenFoodFactsSearchProduct]
}

private struct OpenFoodFactsSearchProduct: Codable {
    let productName: String?
    let brands: String?
    let code: String?
    let nutriments: OpenFoodFactsNutriments?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case code
        case nutriments
    }
}

private struct OpenFoodFactsProduct: Codable {
    let productName: String?
    let brands: String?
    let nutriments: OpenFoodFactsNutriments?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case nutriments
    }
}

private struct OpenFoodFactsNutriments: Codable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?
    let fiber100g: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case fiber100g = "fiber_100g"
    }
}
