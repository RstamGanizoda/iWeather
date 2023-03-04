import UIKit
import RxCocoa
import RxSwift
import CoreLocation


final class SelectedCityViewModel {
    
    // MARK: let/var
    let geocoder = CLGeocoder()
    let disposeBag = DisposeBag()
    let dataSource = DataSource.shared
    let getAllWeather = WeatherManager.shared
    let storageManager = StorageManager.shared
    var weatherData = Weather()
    let defaultLatitude = 37.3172
    let defaultLongtitude = -122.0385
    var allFavoriteCities = AllCities.shared.cityArray
    
    let cityName = BehaviorRelay<String?>(value: "")
    let currentTemp = BehaviorRelay<String?>(value: "")
    let cloudsStatus = BehaviorRelay<String?>(value: "")
    let windSpeed = BehaviorRelay<String?>(value: "")
    let humidity = BehaviorRelay<String?>(value: "")
    let pressure = BehaviorRelay<String?>(value: "")
    let backgroundImage = BehaviorRelay<UIImage?>(value: nil)
    let locationRelay = PublishRelay<CLLocation?>()
    
    let dataSourceDailyForecast = BehaviorRelay<[SearchedDailyTableViewCellModel]>(value: [])
    let dataSourceHourlyForecast = BehaviorRelay<[SearchedHourlyCollectionViewCellModel]>(value: [])
    let addButtonPressed = PublishRelay<Bool>()
    
    // MARK: Functionality
    func addFavoriteCity() {
        addButtonPressed.subscribe { event in
            self.cityName.subscribe { city in
                let foundedCity = City(city: city)
                self.allFavoriteCities?.append(foundedCity)
                self.storageManager.saveCity(array: self.allFavoriteCities)
            }.disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    func fetchWeather() {
        getLocation()
        self.locationRelay.bind { location in
            let latitude = location?.coordinate.latitude
            let longtitude = location?.coordinate.longitude
            self.getAllWeather.getWeather(
                latittude: String(latitude ?? self.defaultLatitude),
                longtitude: String(longtitude ?? self.defaultLongtitude)
            ) { weather in
                self.weatherData = weather
                let currentWeather = self.weatherData.currentWeather
                if let currentTemp = currentWeather?.temp {
                    let roundedTemp = Int(round(currentTemp))
                    self.currentTemp.accept("\(roundedTemp)˚")
                }
                if let clouds = currentWeather?.mainStatus {
                    self.cloudsStatus.accept("\(clouds)")
                }
                if let windSpeed = currentWeather?.windSpeed {
                    self.windSpeed.accept("\(windSpeed) m/s")
                }
                if let humidity = currentWeather?.humidity {
                    self.humidity.accept("\(humidity)%")
                }
                if let pressure = currentWeather?.pressure {
                    self.pressure.accept("\(pressure) hPA")
                }
                if let icon = currentWeather?.icon {
                    self.backgroundImage.accept(IconMapping.mappingForBackground[icon])
                }
                if let dailyForecast = self.weatherData.dailyForecast {
                    let sortedData = dailyForecast.map {
                        SearchedDailyTableViewCellModel(
                            days: $0.date,
                            maxTemp: $0.tempDay,
                            minTemp: $0.tempNight,
                            image: $0.icon)
                    }
                    self.dataSourceDailyForecast.accept(sortedData)
                }
                if let hourlyForecast = self.weatherData.hourlyForecast {
                    let sortedData = hourlyForecast.map {
                        SearchedHourlyCollectionViewCellModel(
                            hours: $0.date,
                            temperature: $0.temp,
                            image: $0.icon
                        )
                    }
                    self.dataSourceHourlyForecast.accept(sortedData)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    func getLocation() {
        dataSource.recievedLocation.subscribe { location in
            let cityLocation = location
            self.locationRelay.accept(cityLocation)
            self.geocoder.reverseGeocodeLocation(cityLocation ??
                                                 CLLocation(latitude: self.defaultLatitude, longitude: self.defaultLongtitude)
            ) { placemark, _ in
                if let city = placemark?.first?.locality {
                    self.cityName.accept(city)
                }
            }
        }.disposed(by: disposeBag)
    }
}
