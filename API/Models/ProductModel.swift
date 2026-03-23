//
//  Item.swift
//  API
//
//  Created by Александр Демьянченко on 13.03.2026.
//

import Foundation
import SwiftData

@Model
final class ProductModel {
    var id:String?
    var title:String
    var price:Double
    var quantity:Int
    
    init(id: String?, title: String, price: Double, quantity: Int) {
        self.id = id
        self.title = title
        self.price = price
        self.quantity = quantity
    }
}
