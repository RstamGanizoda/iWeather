//
//  SearchedDailyTableViewCellModel.swift
//  iWeather
//
//  Created by Rstam Ganizoda on 27/02/2023.
//

import Foundation
import UIKit

final class SearchedDailyTableViewCellModel {
    
    //MARK: let/var
    var days: String? = ""
    var maxTemp: Double? = 0
    var minTemp: Double? = 0
    var image: String? = ""
    
    init(days: String?, maxTemp: Double?, minTemp: Double?, image: String?) {
        self.days = days
        self.maxTemp = maxTemp
        self.minTemp = minTemp
        self.image = image
    }
    
    //MARK: Functionality
    var dayTemp: String? {
        let roundedTemp = Int(round(maxTemp ?? 0))
        return "Day: \(roundedTemp)˚"
    }
    
    var nightTemp: String? {
        let roundedTemp = Int(round(minTemp ?? 0))
        return "Night: \(roundedTemp)˚"
    }
    
    var icon: UIImage? {
        let selectedImage = IconMapping.mapingForWeatherCond
        return selectedImage[image ?? ""]
    }
}
