import CoreLocation
import Foundation
import RxSwift
import RxCocoa

final class SavedCitiesTableViewCellModel {
    
    //MARK: - let/var
    let getAllWeather = WeatherManager.shared
    let dataSource = BehaviorRelay<[City]>(value: [])
    var weatherData = Weather()
    let currentTemp = BehaviorRelay<String?>(value: "")
    let cityRelay = BehaviorRelay<String?>(value: "")
    let backgroundImage = BehaviorRelay<UIImage?>(value: nil)
    let cloudsStatus = BehaviorRelay<String?>(value: "")
    let currentTime = BehaviorRelay<String?>(value: "")
    let disposeBag = DisposeBag()
    var allFavoriteCities = StorageManager.shared.getCity()
    var city: String? = ""
    
    init(city: String?) {
        self.city = city
    }
    
    //MARK: - Functionality
    func fetchWeather() {
        cityRelay.subscribe { city in
            self.getLocationForCity(cityName: city ?? "Berlin") { coordinates, error
                in
                if let coordinates = coordinates {
                    self.getAllWeather.getWeather(
                        latittude: String(coordinates.latitude),
                        longtitude: String(coordinates.longitude)
                    ) { weather in
                        self.weatherData = weather
                        let currentWeather = self.weatherData.currentWeather
                        if let currentTemp = currentWeather?.temp {
                            let roundedTemp = Int(round(currentTemp))
                            self.currentTemp.accept("\(roundedTemp)˚")
                        }
                        if let icon = currentWeather?.icon {
                            self.backgroundImage.accept(IconMapping.mappingForPreviewsBackground[icon])
                        }
                        if let clouds = currentWeather?.mainStatus {
                            self.cloudsStatus.accept("\(clouds)")
                        }
                        if let time = currentWeather?.date{
                            self.currentTime.accept("\(time)")
                        }
                    }
                }
            }
            
        }.disposed(by: disposeBag)
    }
    
    func getLocationForCity(
        cityName: String,
        completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void
    ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            if let error = error {
                completion(nil, error)
            } else if let placemark = placemarks?.first,
                      let location = placemark.location {
                completion(location.coordinate, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
}
