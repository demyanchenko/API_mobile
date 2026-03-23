//
//  APIApp.swift
//  API
//
//  Created by Александр Демьянченко on 13.03.2026.
//

import SwiftUI
import SwiftData

@main
struct APIApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ProductModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    let container = try! ModelContainer(for: ProductModel.self) // создание бд на устройстве с таблицей Продукт
    let productLoader = ProductLoader() // загрузчик модели Продукт
    let dataImporter : DataImporter // импортёр данных
    
    init() {
        self.dataImporter = DataImporter(context: container.mainContext, productLoader: productLoader)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // задача на загрузку данных из АПИ с последующей записью в БД
                    do {
                        // let dataImporter = DataImporter(context: container.mainContext, productLoader: productLoader)
                        try await dataImporter.importData()
                    } catch {
                        print(error)
                    }
                }
        }
        .modelContainer(container)
    }
}
