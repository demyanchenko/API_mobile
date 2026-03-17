//
//  Product.swift
//  API
//
//  Created by Александр Демьянченко on 13.03.2026.
//
// Статья Маттео Манфердини:
// https://matteomanferdini.com/swift-rest-api/

import Foundation
import Combine
import SwiftData

struct Product: Codable {
    var id:String?
    var title:String
    var price:Double
    var quantity:Int
}

/*
 
 Изменить основной объектна тип Hashable (или без типа?, см. класс Item), и добавить расширение для кодирования/декодирования json
 extension User: Codable {
     enum CodingKeys: String, CodingKey {
         case name = "display_name"
         case profileImageURL = "profile_image"
         case reputation
     }
 }
 */

struct APIPutResponse: Codable {
    var data: Product
    var message: String
}

enum APIError: Error, LocalizedError {
    case client
    case server
//    case badURL
//    case badResponse(statusCode: Int)
//    case url(URLError?)
//    case parsing(DecodingError?)
//    case unknown
    var localizedDescription: String {
        switch self {
            case .client: return "Client error"
            case .server: return "Server error"
//            case .badURL, .parsing, .unknown: return "Sorry, something went wrong"
//            case .badResponse(_): return "Sorry, the connection to our server failed"
//            case .url(let error): return error?.localizedDescription ?? "Something went wrong"
        }
    }
//    var description: String {
//        // info for debugging
////        print("Что-то пошло не так")
//    }
}

class ProductViewModel: ObservableObject {
    @Published var products = [Product]()
    @Published var newItem = [Product]()
//    let host = "http://192.168.68.104:8000"
    let host = "http://localhost:8000"
//    let url = host + "/products"
    
    
    // PUT - получение продуктов
    // Async method
    // статья про работу uploadData в запросе POST
    // https://www.tutorialpedia.org/blog/nsurlsession-post-difference-between-uploadtask-and-datatask/
    func addItemSample() async {
        let newItem = Product(id: nil, title: "Decathlon Shirt \n\(Date().formatted(Date.FormatStyle(time: .standard)))", price: 199.99, quantity: 5)
        let url = host + "/product"
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Sample
        let jsonString = "{\"title\": \"Bekka shoes\", \"price\": 15.8, \"quantity\": 1}"
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        print(jsonData)
        
        // request.httpBody = jsonData  // для метода dataTask тело помещается в request
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(
            with: request,
            from: jsonData) { data, response, error in
                // Validate response and call handler
                // Обраотка ошибки
                if let error = error {
                    print("Ошибка чтения данных: \(error)")
                    return
                }
                
                // Обработка кода ответа
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Сервер ответил ошибкой: \(String(describing: response))")
                    print("data="+String(data: jsonData, encoding: .utf8)!)
                    return
                }
                print("HTTP status code: \(httpResponse.statusCode)")
                
//                print(String(data: data!, encoding: .utf8)!)
                if let data = data { //message, data in
                    /*do {
                        // Преобразуем JSON в словарь
                        let json = try JSONSerialization.jsonObject(with: data)
                        print("Получены данные: \(json)")
                    } catch {
                        print("Ошибка парсинга JSON: \(error)")
                    }*/

                    if let decodedResponse = try? JSONDecoder().decode(APIPutResponse.self, from: data) {
                        DispatchQueue.main.async {
//                            self.products = decodedResponse
                            print("Получены данные: \(decodedResponse.data)")
                            print("Получено сообщение: \(decodedResponse.message)")
                        }
                    }
                }
            }
//        )
        task.resume()
        
        print("Data sended")
    }
    
    // DELETE - получение продуктов
    func deleteItem(for itemId : String) {
        let url = host + "/product/" + itemId
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(
            with: request) { data, response, error in
                
                // Обраотка ошибки
                if let error = error {
                    print("Ошибка чтения данных: \(error)")
                    return
                }
                
                // Обработка кода ответа
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Сервер ответил ошибкой: \(String(describing: response))")
                    //                                print("data="+String(data: jsonData, encoding: .utf8)!)
                    return
                }
                print("HTTP status code: \(httpResponse.statusCode)")
                
                if let data = data { //message, data in
                    
                    if let decodedResponse = try? JSONDecoder().decode(Product.self, from: data) {
                        print("Продукт успешно удалён (id): " + decodedResponse.id!)
                        
                    }
                }
            }
        task.resume()
    }
    
    func fetchData() async throws {
        let url = host + "/products"
        guard let url = URL(string: url) else {
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
    
    // GET - получение продуктов
    func fetchProducts() {
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
                let decoder = JSONDecoder()
                if let decodedResponse = try? decoder.decode([Product].self, from: data) {
                    DispatchQueue.main.async {
                        self.products = decodedResponse
                    }
                }
            }
        }.resume()
    }
    
    
    // PUT - отправка данных
    func sendDataAsync(for product: Product/*, withAccessToken token: String*/) async throws {
        let urlPath = host + "/product"
//        let url = URL(string: urlPath)!
        guard let url = URL(string: urlPath) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // TODO: Авторизация по логин:пароль
        // let credentials = "username:password".data(using: .utf8)!.base64EncodedString()
        // request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        
        // TODO: Авторизация по токену
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let data = try JSONEncoder().encode(product)
        
        // .data - получение данных
        // .upload - отправка данных
        let (_, httpResponse) = try await URLSession.shared.upload(for: request, from: data)
        
        // Обработка http-кода в ответе
        guard let httpResponse = httpResponse as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Сервер ответил ошибкой: \(String(describing: httpResponse))")
            return
        }
        
    }
    
    // PUT - отправка данных
        /*func sendDataSync(for product: Product/*, withAccessToken token: String*/) {
        let url = URL(string: "http://192.168.68.104:8000/product")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // TODO: Авторизация по логин:пароль
        // let credentials = "username:password".data(using: .utf8)!.base64EncodedString()
        // request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        
        // TODO: Авторизация по токену
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let data = try? JSONEncoder().encode(product)
        
        // .data - получение данных
        // .upload - отправка данных
        if let data = data {
            let (_, httpResponse) = URLSession.shared.upload(for: request, from: data)
        }
        
        // Обработка http-кода в ответе
        guard let httpResponse = httpResponse as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Сервер ответил ошибкой: \(String(describing: httpResponse))")
            return
        }
        
    }*/
    
    func handleAPIResponse() async throws -> Product {
        let url = URL(string: "http://192.168.68.104:8000/product")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse else {
            throw APIError.server
        }
        switch response.statusCode {
            case 400 ..< 500: throw APIError.client
            case 500 ..< 600: throw APIError.server
            default: break
        }
        return try JSONDecoder().decode(Product.self, from: data)
    }
    
}
