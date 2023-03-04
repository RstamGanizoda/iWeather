//
//  CollectionViewCell.swift
//  iWeather
//
//  Created by Rstam Ganizoda on 27/02/2023.
//

import UIKit

class SearchedHourlyCollectionViewCell: UICollectionViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var weatherConditionsImageView: UIImageView!
    @IBOutlet weak var tempByHoursLabel: UILabel!
    
    //MARK: let/var
    static let identifier = "SearchedHourlyCollectionViewCell"
    let viewModel = SearchedHourlyCollectionViewCellModel(
        hours: "",
        temperature: 0,
        image: ""
    )
    
    //MARK: Functionality
    func configureForecast(_ model: SearchedHourlyCollectionViewCellModel, _ index: Int) {
        if index == 0 {
            self.hoursLabel.text = "Now"
        } else {
            self.hoursLabel.text = model.hours
        }
        self.tempByHoursLabel.text = model.temp
        self.weatherConditionsImageView.image = model.icon
    }
}
