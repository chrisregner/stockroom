//
//  Item.swift
//  stockroom
//
//  Created by Christopher Regner on 2/16/24.
//

import Foundation
import SwiftData

@Model
final class Product: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString

    var timestamp: Date
    var name: String
    var price: Double
    var stock: Int
    var productDescription: String

    init(timestamp: Date, name: String, price: Double, stock: Int, productDescription: String) {
        self.id = UUID().uuidString
        self.timestamp = timestamp
        self.name = name
        self.price = price
        self.stock = stock
        self.productDescription = productDescription
    }

    static func createRandom() -> Product {
        let names = ["Product 1", "Product 2", "Product 3", "Product 4", "Product 5"]
        let descriptions = ["Description 1", "Description 2", "Description 3", "Description 4", "Description 5"]

        let randomIndex = Int.random(in: 0..<names.count)
        let randomPrice = Double.random(in: 1.0...100.0)
        let randomStock = Int.random(in: 0...100)

        return Product(timestamp: Date(), name: names[randomIndex], price: randomPrice, stock: randomStock, productDescription: descriptions[randomIndex])
    }
}
