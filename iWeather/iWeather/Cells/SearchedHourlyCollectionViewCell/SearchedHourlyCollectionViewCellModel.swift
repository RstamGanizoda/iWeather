import Foundation
import UIKit

final class SearchedHourlyCollectionViewCellModel {
    
    //MARK: - let/var
    var hours: String? = ""
    var temperature: Double? = 0
    var image: String? = ""
    
    init(hours: String?, temperature: Double?, image: String?) {
        self.hours = hours
        self.temperature = temperature
        self.image = image
    }
    
    //MARK: - Functionality
    var temp: String? {
        let roundedTemp = Int(round(temperature ?? 0))
        return "\(roundedTemp)˚"
    }
    
    var icon: UIImage? {
        let selectedImage = IconMapping.mapingForWeatherCond
        return selectedImage[image ?? ""]
    }
}
