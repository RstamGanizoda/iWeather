//
//  SavedCitiesTableViewCell.swift
//  iWeather
//
//  Created by Rstam Ganizoda on 28/02/2023.
//
import RxSwift
import RxCocoa
import UIKit

class SavedCitiesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var cloudsStatusLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var weatherConditionImageView: UIImageView!
    
    let viewModel = SavedCitiesTableViewCellModel(city: "")
    static let identifier = "SavedCitiesTableViewCell"
    let disposeBag = DisposeBag()
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        weatherConditionImageView.layer.cornerRadius = 20
    }
    
    
    
    func configureFavoriteCity(_ model: SavedCitiesTableViewCellModel, _ index: Int) {
        viewModel.fetchWeather()
        self.cityLabel.text = model.city
        viewModel.cityRelay.accept(model.city)
        viewModel.currentTemp.subscribe { temp in
            self.currentTemp.text = temp
        }.disposed(by: disposeBag)
        viewModel.backgroundImage.subscribe { icon in
            self.weatherConditionImageView.contentMode = .scaleAspectFill
            self.weatherConditionImageView.image = icon
        }.disposed(by: disposeBag)
        viewModel.cloudsStatus.subscribe { clouds in
            self.cloudsStatusLabel.text = clouds
        }.disposed(by: disposeBag)
        viewModel.currentTime.subscribe { time in
            self.currentTimeLabel.text = time
        }.disposed(by: disposeBag)
    }
}
