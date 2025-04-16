//
//  ProductListViewModel.swift
//  SwiftCatalog
//
//  Created by GS-user on 16/04/25.
//

import Foundation
import Combine

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var filters = FilterOptions() {
        didSet {
            applyFilters(filters)
        }
    }

    @Published var favorites: Set<Int> = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchProducts()
    }

    func fetchProducts() {
        WebService.shared.fetchProducts()
            .sink { completion in
                if case let .failure(error) = completion {
                    print("Error fetching products: \(error)")
                }
            } receiveValue: { [weak self] products in
                self?.products = products
                self?.applyFilters(self?.filters ?? FilterOptions())
            }
            .store(in: &cancellables)
    }

    func toggleFavorite(for product: Product) {
        if favorites.contains(product.id) {
            favorites.remove(product.id)
        } else {
            favorites.insert(product.id)
        }

        // Update isFavorite flags
        updateIsFavoriteStatus()
    }

    func applyFilters(_ filter: FilterOptions) {
        filteredProducts = products.filter { product in
            let matchesCategory = filter.category == .all || product.category == filter.category.rawValue
            let matchesPrice = filter.priceRange?.contains(product.price) ?? true
            return matchesCategory && matchesPrice
        }

        updateIsFavoriteStatus()
    }

    var favoriteProducts: [Product] {
        products
            .filter { favorites.contains($0.id) }
            .map { product in
                var updated = product
                updated.isFavorite = true
                return updated
            }
    }

    private func updateIsFavoriteStatus() {
        // Update favorites in filtered list
        filteredProducts = filteredProducts.map { product in
            var updated = product
            updated.isFavorite = favorites.contains(product.id)
            return updated
        }
    }
}
