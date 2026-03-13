//
//  Product.swift
//  API
//
//  Created by Александр Демьянченко on 13.03.2026.
//

import Foundation
import Combine

struct Product: Codable {
    var title:String
    var price:Double
    var quantity:Int
}


class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    
    func fetchData() async {
        guard let url = URL(string: "http://192.168.68.105:8000/products") else {
            print("This URL is not working!")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let decodedResponse = try? JSONDecoder().decode([Product].self, from: data) {
                products = decodedResponse
            }
        } catch {
            print("These data are not valid")
        }
    }
    
    // Call API and update products array
    func fetchProducts() {
        guard let url = URL(string: "http://192.168.68.105:8000/products") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                if let decodedResponse = try? decoder.decode([Product].self, from: data) {
                    DispatchQueue.main.async {
                        self.products = decodedResponse
                    }
                }
            }
        }.resume()
    }
}
