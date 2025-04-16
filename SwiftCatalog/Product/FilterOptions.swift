//
//  FilterOptions.swift
//  SwiftCatalog
//
//  Created by GS-user on 16/04/25.
//

import Foundation

enum ProductCategory: String, CaseIterable, Codable {
    case all
    case electronics
    case jewelery
    case menClothing = "men's clothing"
    case womenClothing = "women's clothing"

    var displayName: String {
        switch self {
        case .all: return "All"
        case .electronics: return "Electronics"
        case .jewelery: return "Jewelry"
        case .menClothing: return "Men's"
        case .womenClothing: return "Women's"
        }
    }
}

struct FilterOptions: Equatable {
    var category: ProductCategory = .all
    var priceRange: ClosedRange<Double>? = 0...1000
}
