//
//  Cities.swift
//  iWeather
//
//  Created by Rstam Ganizoda on 28/02/2023.
//

import Foundation

class AllCities: Codable {
    
    static let shared = AllCities()
    var cityArray: [City]?
    
    init() {
        cityArray = []
    }
}

class City: Codable, Equatable {
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.city == rhs.city
    }
    var city: String?
    
    init(city: String?) {
        self.city = city
    }
}
