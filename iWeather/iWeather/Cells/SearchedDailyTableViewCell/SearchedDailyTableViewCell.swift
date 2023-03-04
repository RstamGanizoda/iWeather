//
//  SearchedDailyTableViewCell.swift
//  iWeather
//
//  Created by Rstam Ganizoda on 27/02/2023.
//

import UIKit

class SearchedDailyTableViewCell: UITableViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherConditionImageView: UIImageView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    
    //MARK: let/var
    static let identifier = "SearchedDailyTableViewCell"
    let viewModel = SearchedDailyTableViewCellModel(
        days: "",
        maxTemp: 0,
        minTemp: 0,
        image: ""
    )

    //MARK: Functionality
    func configureDailyForecast(_ model: SearchedDailyTableViewCellModel, _ index: Int) {
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
