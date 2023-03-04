import Foundation
import Alamofire

class WeatherManager {
    
    //MARK: let/var
    static let shared = WeatherManager()
    private init(){}
    
    private let baseURL = "https://api.openweathermap.org/data/3.0/onecall?"
    private let latitudeURL = "lat="
    private let longtitudeURL = "&lon="
    private let extraKey = "&appid=f7de4cef632bf95e15574a571348a79d"
    private let keyApi = "&appid=efc102590e9138889b4c5376d0730c86"

    private let units = "&units=metric"
    private let defaultTimezone = "America/Los_Angeles"
    let weatherData = Weather()
    
    //MARK: Functionality
    func getWeather(
        latittude: String,
        longtitude: String,
        completion: @escaping (Weather) -> ()
    ) {
        let urlString = baseURL + latitudeURL + latittude + longtitudeURL + longtitude + keyApi + units
        AF.request(urlString).response { response in
            guard let data = response.data,
                  let JSONSerialization = try? JSONSerialization.jsonObject(with: data) else { return }
            
            if let json = JSONSerialization as? [String: Any] {
                let currentWeather = WeatherParameters()
                var hourlyWeather = [WeatherParameters]()
                var dailyWeather = [WeatherParameters]()
                // current weather
                if let timezone = json["timezone"] as? String {
                    self.weatherData.timezone = timezone
                }
                if let current = json["current"] as? [String: Any] {
                    if let mainStatus = current["main"] as? String {
                        currentWeather.mainStatus = mainStatus
                    }
                    if let time = current["dt"] as? Double {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        formatter.timeZone = TimeZone(identifier: self.weatherData.timezone ?? self.defaultTimezone)
                        currentWeather.date = formatter.string(from: Date(timeIntervalSince1970: time))
                    }
                    if let temp = current["temp"] as? Double {
                        currentWeather.temp = temp
                    }
                    if let humidity = current["humidity"] as? Int {
                        currentWeather.humidity = humidity
                    }
                    if let pressure = current["pressure"] as? Int {
                        currentWeather.pressure = pressure
                    }
                    if let windSpeed = current["wind_speed"] as? Double {
                        currentWeather.windSpeed = windSpeed
                    }
                    if let weatherGroup = current["weather"] as? [[String: Any]] {
                        var weatherList = [WeatherParameters]()
                        for weather in weatherGroup {
                            let weatherParameters = WeatherParameters()
                            if let main = weather["main"] as? String {
                                currentWeather.mainStatus = main
                            }
                            if let description = weather["description"] as? String {
                                currentWeather.description = description
                            }
                            if let icon = weather["icon"] as? String {
                                currentWeather.icon = icon
                            }
                            weatherList.append(weatherParameters)
                        }
                    }
                    self.weatherData.currentWeather = currentWeather
                    
                    //hourly forecast
                    if let hourly = json["hourly"] as? [[String: Any]] {
                        for i in 0...23 {
                            let weatherForHour = WeatherParameters()
                            if let date = hourly[i]["dt"] as? Double {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH"
                                formatter.timeZone = TimeZone(identifier: self.weatherData.timezone ?? self.defaultTimezone)
                                weatherForHour.date = formatter.string(from: Date(timeIntervalSince1970: date))
                            }
                            if let temp = hourly[i]["temp"] as? Double {
                                weatherForHour.temp = temp
                            }
                            if let weather = hourly[i]["weather"] as? [[String: Any]],
                               let icon = weather.first?["icon"] as? String {
                                weatherForHour.icon = icon
                            }
                            hourlyWeather.append(weatherForHour)
                        }
                    }
                    self.weatherData.hourlyForecast = hourlyWeather
                    
                    //daily forecast   
                    if let daily = json["daily"] as? [[String: Any]] {
                        for day in daily {
                            let weatherForDay = WeatherParameters()
                            if let date = day["dt"] as? Double {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "EEEE"
                                formatter.timeZone = TimeZone(identifier: self.weatherData.timezone ?? self.defaultTimezone)
                                weatherForDay.date = formatter.string(from: Date(timeIntervalSince1970: date))
                            }
                            if let temp = day["temp"] as? [String: Any] {
                                if let tempDay = temp["day"] as? Double{
                                    weatherForDay.tempDay = tempDay
                                }
                                if let tempNight = temp["night"] as? Double{
                                    weatherForDay.tempNight = tempNight
                                }
                            }
                            if let weather = day["weather"] as? [[String: Any]],
                               let icon = weather.first?["icon"] as? String {
                                weatherForDay.icon = icon
                            }
                            dailyWeather.append(weatherForDay)
                        }
                        self.weatherData.dailyForecast = dailyWeather
                        completion(self.weatherData)
                    }
                }
            }
        }
    }
}
        
