//
//  Network.swift
//  API
//
//  Created by Александр Демьянченко on 19.03.2026.
//

import Foundation
import Combine
import SwiftData

struct Networking {
    var urlSession = URLSession.shared
    let host = "http://localhost:8000"
    
    // GET - получение продуктов
    func getRequest() {
        let url = host + "/products"
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            // Обраотка ошибки
            if let error = error {
                print("Ошибка чтения данных: \(error)")
                return
            }
            
            // Обработка кода ответа
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Сервер ответил ошибкой: \(String(describing: response))")
                return
            }
            
            if let data = data {
//                let products = try JSONDecoder().decode([ProductAPI].self, from: data!)
                
                let decoder = JSONDecoder()
                if let decodedResponse = try? decoder.decode([ProductAPI].self, from: data) {
//                    return decodedResponse
                    DispatchQueue.main.async {
                        let products = decodedResponse
                    }
                }
            }
            
        }.resume()
    }
    
    func sendPostRequest(
        to url: URL,
        body: Data,
        //        then handler: @escaping (Result) -> Void
    ) {
        // To ensure that our request is always sent, we tell
        // the system to ignore all local cache data:
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        
        request.httpMethod = "POST"
        request.httpBody = body
        
        let task = urlSession.dataTask(
            with: request,
            completionHandler: { data, response, error in
                // Validate response and call handler
                //                ...
            }
        )
        
        /*
         let task = urlSession.uploadTask(
             with: request,
             from: body,
             completionHandler: { data, response, error in
                 // Validate response and call handler
                 ...
             }
         */
        
        task.resume()
    }
    // DELETE - удаление продукта
    func deteleRequest() {
        let url = host + "/product"
        guard let url = URL(string: url) else { return }
    }
}
