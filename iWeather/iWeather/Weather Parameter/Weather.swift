import Foundation

//MARK: - class
class Weather {
    
    //MARK: - let/var
    var timezone: String?
    var currentWeather: WeatherParameters?
    var hourlyForecast: [WeatherParameters]?
    var dailyForecast: [WeatherParameters]?
}
