import UIKit
import CoreLocation
import RxCocoa
import RxSwift

//MARK: - extension
private extension Double {
    static let defaultLatitude = 37.3172
    static let defaultLongtitude = -122.0385
}

final class CurrentWeatherViewModel {
    
    // MARK: - let/var
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    let searchCityViewContoller = "SearchCityViewController"
    let getAllWeather = WeatherManager.shared
    var weatherData = Weather()
    let disposeBag = DisposeBag()
    let cityName = BehaviorRelay<String>(value: "")
    let currentTemp = BehaviorRelay<String?>(value: "")
    let cloudsStatus = BehaviorRelay<String?>(value: "")
    let windSpeed = BehaviorRelay<String?>(value: "")
    let humidity = BehaviorRelay<String?>(value: "")
    let pressure = BehaviorRelay<String?>(value: "")
    let backgroundImage = BehaviorRelay<UIImage?>(value: nil)
    let dataSourceDailyForecast = BehaviorRelay<[DailyTableViewCellModel]>(value: [])
    let dataSourceHourlyForecast = BehaviorRelay<[HourlyCollectionViewCellModel]>(value: [])
    let searchButtonPressed = PublishRelay<Bool>()
    let searchViewController = PublishRelay<UIViewController>()
    
    //MARK: - Navigation
    func configureSearchButton() {
        searchButtonPressed.subscribe { event in
            self.searchViewController.accept(self.createSearchController())
        }.disposed(by: disposeBag)
    }
    
    func createSearchController() -> UIViewController {
        guard let controller = UIStoryboard(
            name: "Main",
            bundle: nil)
            .instantiateViewController(withIdentifier: self.searchCityViewContoller) as? SearchCityViewController else { return UIViewController() }
        return controller
    }
    
    // MARK: - Functionality
    func fetchWeather(){
        let latitude = getCurrentLocation().coordinate.latitude
        let longtitude = getCurrentLocation().coordinate.longitude
        getCityName()
        
        getAllWeather.getWeather(
            latittude: String(latitude),
            longtitude: String(longtitude)
        ){  weather in
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
                    DailyTableViewCellModel(
                        days: $0.date,
                        maxTemp: $0.tempDay,
                        minTemp: $0.tempNight,
                        image: $0.icon)
                }
                self.dataSourceDailyForecast.accept(sortedData)
            }
            if let hourlyForecast = self.weatherData.hourlyForecast {
                let sortedData = hourlyForecast.map {
                    HourlyCollectionViewCellModel(
                        hours: $0.date,
                        temperature: $0.temp,
                        image: $0.icon
                    )
                }
                self.dataSourceHourlyForecast.accept(sortedData)
            }
        }
    }
    
    func getCityName(){
        let location = getCurrentLocation()
        geocoder.reverseGeocodeLocation(location) { placemark, _ in
            if let city = placemark?.first?.locality{
                self.cityName.accept(city)
            }
        }
    }
    
    func getCurrentLocation() -> CLLocation {
        let defaultCoordinates = CLLocation(
            latitude: .defaultLatitude,
            longitude: .defaultLongtitude
        )
        guard let latitude = locationManager.location?.coordinate.latitude,
              let longtitude = locationManager.location?.coordinate.longitude else { return defaultCoordinates }
        let location = CLLocation(
            latitude: latitude,
            longitude: longtitude
        )
        return location
    }
}
