//
//  ContentView.swift
//  SwiftCatalog
//
//  Created by GS-user on 16/04/25.
//

import SwiftUI


extension Color {
    static let customTeal = Color(red: 81/255, green: 179/255, blue: 174/255) // Hex: #51B3AE
}


struct ProductListView: View {
    @StateObject var viewModel = ProductListViewModel()
    @State private var showFavorites = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.customTeal.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 🔍 Filter Section -  single row layout
                    HStack(spacing: 16) {
                        // Category Picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Category")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Picker("", selection: $viewModel.filters.category) {
                                ForEach(ProductCategory.allCases, id: \.self) { category in
                                    Text(category.displayName).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(height: 60)
                            .tint(.white)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(10)
                        }
                        .frame(height: 100)

                        // Price Slider
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Price")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundColor(.white.opacity(0.8))
                            
                            if let priceRange = viewModel.filters.priceRange {
                                HStack(spacing: 12) {
                                    Slider(
                                        value: Binding(
                                            get: { priceRange.upperBound },
                                            set: { newVal in
                                                viewModel.filters.priceRange = priceRange.lowerBound...newVal
                                            }
                                        ),
                                        in: 0...1000,
                                        step: 10
                                    )
                                    .tint(.white)
                                    
                                    Text("$\(Int(priceRange.upperBound))")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 50)
                                }
                                .frame(height: 45)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                            }
                        }
                        .frame(height: 100)

                        // Favorites Button
                        VStack(spacing: 6) {
                            Text("Favorites")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button(action: { showFavorites.toggle() }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "heart.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                    
                                    if !viewModel.favoriteProducts.isEmpty {
                                        Text("\(viewModel.favoriteProducts.count)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Circle().fill(Color.black))
                                            .offset(x: 6, y: -6)
                                    }
                                }
                                .padding(12)
                                .frame(width: 60,height: 60)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                            }
                        }
                        .frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                    // Scrollable list of products
                    ScrollView {
                        VStack(spacing: 16) {
                            // ❤️ Favorites Section
                            if showFavorites, !viewModel.favoriteProducts.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("YOUR FAVORITES")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.horizontal, 16)
                                    
                                    ForEach(viewModel.favoriteProducts) { product in
                                        ProductRow(product: product) {
                                            viewModel.toggleFavorite(for: product)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }

                            // 🛍 Filtered Product List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ALL PRODUCTS")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 16)
                                
                                ForEach(viewModel.filteredProducts) { product in
                                    ProductRow(product: product) {
                                        viewModel.toggleFavorite(for: product)
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationTitle("Product Feed")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProductRow: View {
    let product: Product
    let toggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Product Image
            if let imageUrl = product.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(10)
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }

            // Product Details
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("$\(product.price, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Favorite Button
            Button(action: toggleFavorite) {
                Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .foregroundColor(product.isFavorite ? .red : .white.opacity(0.7))
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFill()
            .frame(width: 60, height: 60)
            .clipped()
            .foregroundColor(.white.opacity(0.3))
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
    }
}
