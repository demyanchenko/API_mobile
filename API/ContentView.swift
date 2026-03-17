//
//  ContentView.swift
//  API
//
//  Created by Александр Демьянченко on 13.03.2026.
//
// Статья по работе с АПИ:
// https://proglib.io/p/setevye-zaprosy-i-rest-api-v-ios-i-swift-protokolno-orientirovannoe-programmirovanie-chast-1-2023-03-02

import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    @StateObject private var productViewModel = ProductViewModel()  // Вариант с менеджером fetch
    //@State private var products = [Product]()   // вариант с встроенным fetch
    
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [Item]
    
    private var students: [Student]?
//    var action: () async -> Void

    var body: some View {
        
        
        NavigationSplitView {
            List {
                ForEach(/*productViewModel.*/products, id: \.title) { product in
                    NavigationLink {
                        Text("\(product.title/*, format: Date.FormatStyle(date: .numeric, time: .standard)*/)")
                            .font(.title)
                            .padding()
                        Text("Цена: \(product.price)")
                        Text("В наличии \(product.quantity) шт.")
                    } label: {
                        Text(product.title)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .refreshable {
                getItems()
                print("Event: refresh")
            }
            .task {
                do {
                    try await getItems()
                } catch {
                    print("error task")
                }
                print("Event: task")
            }
            /*List {
                ForEach(products, id: \.title) { item in

                    NavigationLink {
                        Text("\(item.title/*, format: Date.FormatStyle(date: .numeric, time: .standard)*/)")
                            .font(.title)
                            .padding()
                        Text("Цена: \(item.price)")
                        Text("В наличии \(item.quantity) шт.")
                    } label: {
                        Text(item.title)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .task {
                await fetchData()
            }*/
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: getItems) {
                        Label("Обновить", systemImage: "arrow.trianglehead.2.clockwise")
                    }
                }
                ToolbarItem {
                    AsyncButton(action: productViewModel.addItemSample) {
                        Label("Добавить", systemImage: "plus")
                    }
                }

                
            }
        } detail: {
            Text("Select an item")
        }

    }
    
    func fetchData() async { // <2>
        // Simulate a network request
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        print("Data fetched")
    }
    
    /* вариант реализации встроенного fetch
     func fetchData() async {
        guard let url = URL(string: "http://192.168.68.105:8000/products") else {
            print("URL не валидный!")
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
    }*/
    
    private func getItems() {
        withAnimation {
            
            // Получаем данные из API
            productViewModel.fetchProducts()
            
            // Очищаем список в БД
            for product in products {
                modelContext.delete(product)
            }
            // Заполняем список в БД заново
            for product in productViewModel.products {
                modelContext.insert(Item(id: product.id, title: product.title, price: product.price, quantity: product.quantity))
            }
        }
    }
    
    @MainActor
    private func addItem() async -> Void {
//        withAnimation {
        let newItem = Product(id: nil, title: "Decathlon Shirt \n\(Date().formatted(Date.FormatStyle(time: .standard)))", price: 199.99, quantity: 5)
        //            modelContext.insert(newItem)
        
        // todo: реализовать PUT запрос к API
        try? await productViewModel.sendDataAsync(for: newItem)
        //            products.append(newItem)
        //productViewModel.products.append(newItem)
        modelContext.insert(Item(id: newItem.id, title: newItem.title, price: newItem.price, quantity: newItem.quantity))
//        }
    }

    private func deleteItems(offsets: IndexSet)   {
//        withAnimation {
            for index in offsets {
                modelContext.delete(products[index])
                productViewModel.products.remove(at: index)
                Task {
                    productViewModel.deleteItem(for: String(products[index].id!))
                    
                }
            }
        
            

//        }
    }
}

final class NetworkManager {
    
    var students: [Student] = []
    
    
    func fetchStudents(completionHandler: @escaping ([Student]) -> Void) {
        let url = URL(string: "http://192.168.68.105:8000/students")!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching films: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let data = data,
               let student = try? JSONDecoder().decode([Student].self, from: data) {
//                completionHandler(student)
                DispatchQueue.main.async { completionHandler(student) }
            }
        })
        task.resume()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
