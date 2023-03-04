

import UIKit

class DailyTableViewCell: UITableViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherConditionImageView: UIImageView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    
    //MARK: let/var
    static let identifier = "DailyTableViewCell"
    let viewModel = DailyTableViewCellModel(
        days: "",
        maxTemp: 0,
        minTemp: 0,
        image: ""
    )
    //MARK: Functionality
    func configureDailyForecast(_ model: DailyTableViewCellModel, _ index: Int) {
        if index == 0 {
            self.dayLabel.text = "Today"
        } else {
            self.dayLabel.text = model.days
        }
        self.maxTempLabel.text = model.dayTemp
        self.minTempLabel.text = model.nightTemp
        self.weatherConditionImageView.image = model.icon
    }
}
