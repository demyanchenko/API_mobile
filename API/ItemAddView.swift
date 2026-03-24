//
//  ItemsView.swift
//  API
//
//  Created by Александр Демьянченко on 13.03.2026.
//

import SwiftUI
import SwiftData
import Foundation

struct ItemAddView: View {
    @State private var title: String = ""
    @State private var price: String = ""
    @State private var quantity: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var productViewModel = ProductViewModel()  // Вариант с менеджером fetch
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [ProductModel]
    
//    let namespace: Namespace.ID
    
//    @Binding var actionItemAdd: Bool
    
    
    var body: some View {
//        NavigationStack {}
        
        VStack {
            TextFieldView(value: $title, placeholder: "Заголовок", image: "pencil.line")
            TextFieldView(value: $price, placeholder: "Цена", image: "rublesign", keyboardType: .numberPad)
            TextFieldView(value: $quantity, placeholder: "Количество", image: "numbers", keyboardType: .numberPad)
            /*Button(action: {
                Task {
                    do {
                        try await productViewModel.addItemSample()
                    } catch {
                        print("error task")
                    }
                }
            }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue)
                    .frame(width: 150, height: 50)
                    .overlay {
                        Text("Добавить").foregroundColor(.white)
                    }
            }*/
        }
        .navigationTitle("Добавить запись")
//        .navigationBarTitleDisplayMode(Image(systemName: "rublesign"))
        .navigationBarBackButtonHidden(true)
        //.animation(.easeInOut(duration: 0.5), value: true).navigationTitle("")//.navigationBarHidden(true)
        .toolbar {
            
            // Кнопка "Закрыть"
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Закрыть", systemImage: "xmark", role: .cancel) {
//                    actionItemAdd = false
                    dismiss()
                }
            }
            
            // Кнопка "Сохранить"
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить", systemImage: "checkmark", role: .confirm) {
//                    actionItemAdd = false
                    Task {
                            try await addItem()
                    }
                }
            }
            
        }
        //.matchedGeometryEffect(id: "image_plus", in: namespace)
    }
    
    @MainActor
    private func addItem() async -> Void {
//        withAnimation {
        if title != "" && price != "" && quantity != "" {
            let newItem = ProductAPI(id: nil, title: title, price: Double(self.price) ?? 0, quantity: Int(quantity) ?? 0)
            // Выполняем PUT запрос к API Bmai 
            try? await productViewModel.sendDataAsync(for: newItem)
            
            // Добавляем в локальный список
            modelContext.insert(ProductModel(id: newItem.id, title: newItem.title, price: newItem.price, quantity: newItem.quantity))
            print("Кнопка Сохранить успешно отработала.")
//            actionItemAdd = false
            dismiss()
        } else {
            print("Польователь не ввел данные!")
        }
    }
}

struct TextFieldView: View {
    @Binding var value: String
    var placeholder: String?
    var image: String?
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            if let imageName = image {
                Image(systemName: imageName)
                    .padding(.leading)
                    .padding(.vertical)
            }
            TextField(text: $value) {
                if let placeholder = placeholder {
                    Text(placeholder).foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            .padding()
            .keyboardType(keyboardType)
            .submitLabel(.done)
        }
//        .background(.mint)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 1) )
//        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    @Previewable @State  var title: String = ""
    @Previewable @State  var price: Double = 0
    @Previewable @State  var quantity: Int = 0
//    @Previewable @Namespace var namespace: Namespace.ID
//    @Previewable @State var actionItemAdd: Bool = true
    
    ItemAddView(/*namespace: namespace*/)
}
