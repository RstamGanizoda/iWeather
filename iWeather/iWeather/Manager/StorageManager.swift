import Foundation

private extension String {
    
    static let cityKey = "cityKey"
}

class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    // Save and load cities
    func saveCity(array: [City]?) {
        guard var allCities = getCity() else {
            UserDefaults.standard.set(encodable: array, forKey: .cityKey)
            return
        }
        if let newCities = array {
                for city in newCities {
                    if !allCities.contains(city) {
                        allCities.append(city)
                    }
                }
            }
            UserDefaults.standard.set(encodable: allCities, forKey: .cityKey)
    }
    
    func getCity() -> [City]? {
        guard let array = UserDefaults.standard.value([City].self, forKey: .cityKey) else {return nil}
        return array
    }
}

// MARK: Extension UserDefaults
extension UserDefaults {
    
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    func value<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data){
            return value
        }
        return nil
    }
}
