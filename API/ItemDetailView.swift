//
//  ItemDetailView.swift
//  API
//
//  Created by Александр Демьянченко on 19.03.2026.
//

import SwiftUI

struct ItemDetailView: View {
    var product: ProductModel
//    let namespace: Namespace.ID
    
    var body: some View {
        VStack{
            Text("\(product.title/*, format: Date.FormatStyle(date: .numeric, time: .standard)*/)")
                .font(.title)
                .padding()
//                .matchedGeometryEffect(id: "title_\(String(describing: product.id))", in: namespace)
                .transition(.opacity.combined(with: .scale))
            Text("Цена: \(product.price)")
            Text("В наличии \(product.quantity) шт.")
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable var product: ProductModel = .init(id: "1", title: "Товар", price: 100, quantity: 10)
//    @Previewable @Namespace var namespace: Namespace.ID
        
    ItemDetailView(product: product/*, namespace: namespace*/)
}
