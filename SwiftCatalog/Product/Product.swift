//
//  Product.swift
//  SwiftCatalog
//
//  Created by GS-user on 16/04/25.
//

import Foundation
struct Product: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let category: String
    let price: Double
    var isFavorite: Bool = false
    let image: String?
    
    enum CodingKeys: String, CodingKey {
            case id
            case title
            case category
            case price
            case image
    }
}
