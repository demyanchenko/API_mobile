//
//  DataImporter.swift
//  API
//
//  Created by Александр Демьянченко on 20.03.2026.
//

import Foundation
import SwiftData

struct DataImporter {
    let context: ModelContext
    let productLoader: ProductLoader
    
    @MainActor
    func importData() async throws {
        
        // predicate to fetch ProductModel objects usin SwiftData
        var productDescriptor = FetchDescriptor<ProductModel>()
        // set limit to 1
        productDescriptor.fetchLimit = 1 // можно заменить на .first применимый к .fetch(), но с ущербом для нагрузки, поскольку сначала fetch запросит все данные.
        
        let persistedProduct = try context.fetch(productDescriptor)
        
        if persistedProduct.isEmpty {
            
            let products = try await productLoader.loadProduct()
            
            if !products.isEmpty {
                // insert data into on-device database
                products.forEach { product in
                    let productModel = ProductModel(id: product.id, title: product.title, price: product.price, quantity: product.quantity)
                    context.insert(productModel)
                }
            }
        }

        
    }
    
}
