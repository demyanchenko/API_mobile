//
//  Student.swift
//  API
//
//  Created by Александр Демьянченко on 13.03.2026.
//

import Foundation
import SwiftData

// Простая реализация
struct Student: Codable {
    let student_id: Int
    let first_name: String
    let last_name: String
    let date_of_birth: String
    let email: String
    let phone_number: String
    let address: String
    let enrollment_year: Int
    let major: String
    let course: Int
    let special_notes: String
}

// Другая реализация модели с явным описанием декодинга
struct StudentItem: Identifiable {
    let id: Int
    let first_name: String
    let last_name: String
    let date_of_birth: String
    let email: String
    let phone_number: String
    let address: String
    let enrollment_year: Int
    let major: String
    let course: Int
    let special_notes: String
}

/*final class Student {
    let id: Int
    let first_name: String
    let last_name: String
    let date_of_birth: String
    let email: String
    let phone_number: String
    let address: String
    let enrollment_year: Int
    let major: String
    let course: Int
    let special_notes: String
    
    init(id: Int, first_name: String, last_name: String, date_of_birth: String, email: String, phone_number: String, address: String, enrollment_year: Int, major: String, course: Int, special_notes: String) {
        self.id = id
        self.first_name = first_name
        self.last_name = last_name
        self.date_of_birth = date_of_birth
        self.email = email
        self.phone_number = phone_number
        self.address = address
        self.enrollment_year = enrollment_year
        self.major = major
        self.course = course
        self.special_notes = special_notes
    }
   
}*/

extension StudentItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case first_name, last_name, date_of_birth, email, phone_number, address, enrollment_year, major, course, special_notes
        case id = "student_id"
    }
}

struct Wrapper {
    let items: [StudentItem]
}
