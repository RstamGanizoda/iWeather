import Foundation

//MARK: - class
final class AllCities: Codable {
    
    //MARK: - let/var
    static let shared = AllCities()
    var cityArray: [City]?
    
    init() {
        cityArray = []
    }
}

//MARK: - class
final class City: Codable, Equatable {
    
    //MARK: - let/var
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.city == rhs.city
    }
    var city: String?
    
    init(city: String?) {
        self.city = city
    }
}
