//
//  HourlyCollectionViewCell.swift
//  iWeather
//
//  Created by Rstam Ganizoda on 22/01/2023.
//

import UIKit
import RxSwift
import RxCocoa

class HourlyCollectionViewCell: UICollectionViewCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tempByHours: UILabel!
    
    //MARK: let/var
    static let identifier = "HourlyCollectionViewCell"
    let viewModel = HourlyCollectionViewCellModel(
        hours: "",
        temperature: 0,
        image: ""
    )
    
    //MARK: Functionality
    func configureForecast(_ model: HourlyCollectionViewCellModel, _ index: Int) {
        if index == 0 {
            self.hoursLabel.text = "Now"
        } else {
            self.hoursLabel.text = model.hours
        }
        self.tempByHours.text = model.temp
        self.weatherImageView.image = model.icon
    }
}
