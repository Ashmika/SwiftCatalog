//
//  WebService.swift
//  SwiftCatalog
//
//  Created by GS-user on 16/04/25.
//

import Foundation
import Combine

class WebService {
    static let shared = WebService()
    
    func fetchProducts() -> AnyPublisher<[Product], Error> {
        guard let url = URL(string: "https://fakestoreapi.com/products") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
