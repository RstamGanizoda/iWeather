//
//  SelectedCityViewController.swift
//  iWeather
//
//  Created by Rstam Ganizoda on 26/02/2023.
//

import UIKit
import CoreLocation
import RxCocoa
import RxSwift

private extension CGFloat {
    static let space = 10.0
    static let cornerRadius = CGFloat(20)
    static let heightOfRows = CGFloat(60)
    static let heightForHeader = CGFloat(30)
    static let alphaForBackground = CGFloat(0.15)
    static let alphaForHeader = CGFloat(0.95)
    static let widthOfCollections = CGFloat(60)
}

class SelectedCityViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var windImageView: UIImageView!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityImageView: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var pressureImaageView: UIImageView!
    @IBOutlet weak var cloudsStatusLabel: UILabel!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: let/var
    let viewModel = SelectedCityViewModel()
    let disposeBag = DisposeBag()

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.addFavoriteCity()
        addIcons()
        modifyHourlyCollectionView()
        modifyDailyTableView()
        getCurrentWeather()
        configureDailyForecast()
        configureHourlyForecast()
    }
    
    //MARK: IBAction
    @IBAction func addButtonPressed(_ sender: UIButton) {
        viewModel.addButtonPressed.accept(true)
        self.dismiss(animated: true)

    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: UI
    private func addIcons(){
        let windIcon = UIImage(named: "windIcon")
        let humidityIcon = UIImage(named: "humidityIcon")
        let pressureIcon = UIImage(named: "pressureIcon")
        
        self.windImageView.image = windIcon
        self.humidityImageView.image = humidityIcon
        self.pressureImaageView.image = pressureIcon
    }
    
    private func modifyHourlyCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(
            width: .widthOfCollections,
            height: self.hourlyCollectionView.frame.height - .space * 2
        )
        hourlyCollectionView.layer.cornerRadius = .cornerRadius
        hourlyCollectionView.setCollectionViewLayout(layout, animated: true)
        hourlyCollectionView.contentInset = UIEdgeInsets(
            top: CGFloat.space,
            left: CGFloat.space,
            bottom: CGFloat.space,
            right: CGFloat.space
        )
        hourlyCollectionView.isOpaque = false
        hourlyCollectionView.backgroundColor = .white.withAlphaComponent(.alphaForBackground)
    }
    
    private func modifyDailyTableView(){
        dailyTableView.layer.cornerRadius = .cornerRadius
        dailyTableView.allowsSelection = false
        dailyTableView.backgroundColor = .white.withAlphaComponent(.alphaForBackground)
        if #available(iOS 15.0, *) {
            dailyTableView.sectionHeaderTopPadding = .zero
        }
    }
    
    private func getCurrentWeather() {
        viewModel.fetchWeather()
        viewModel.cityName.subscribe { city in
            self.cityLabel.text = city
        }.disposed(by: disposeBag)
        viewModel.currentTemp.subscribe { temperature in
            self.currentTempLabel.text = temperature
        }.disposed(by: disposeBag)
        
        viewModel.cloudsStatus.subscribe { clouds in
            self.cloudsStatusLabel.text = clouds
        }.disposed(by: disposeBag)
        
        viewModel.windSpeed.subscribe { windSpeed in
            self.windSpeedLabel.text = windSpeed
        }.disposed(by: disposeBag)
        
        viewModel.humidity.subscribe { humidity in
            self.humidityLabel.text = humidity
        }.disposed(by: disposeBag)
        
        viewModel.pressure.subscribe { pressure in
            self.pressureLabel.text = pressure
        }.disposed(by: disposeBag)
        
        viewModel.backgroundImage.subscribe { backgroundImage in
            self.backgroundImageView.contentMode = .scaleAspectFill
            self.backgroundImageView.image = backgroundImage
        }.disposed(by: disposeBag)
    }
    
    private func configureHourlyForecast() {
        viewModel.dataSourceHourlyForecast.bind(
            to: hourlyCollectionView.rx.items(
                cellIdentifier: SearchedHourlyCollectionViewCell.identifier,
                cellType: SearchedHourlyCollectionViewCell.self
            )
        ) { index, model, cell in
            cell.configureForecast(model, index)
        }.disposed(by: disposeBag)
    }
    
    private func configureDailyForecast(){
        viewModel.dataSourceDailyForecast.bind(
            to: dailyTableView.rx.items(
                cellIdentifier: SearchedDailyTableViewCell.identifier,
                cellType: SearchedDailyTableViewCell.self
            )
        ) { index, model, cell in
            cell.configureDailyForecast(model, index)
        }.disposed(by: disposeBag)
        self.dailyTableView.delegate = self
    }
}

//MARK: extensions
extension SelectedCityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .heightOfRows
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(
            x: tableView.bounds.origin.x,
            y: tableView.bounds.origin.y,
            width: tableView.bounds.width,
            height: .heightForHeader
        )
        let headerView = UIView(frame: frame)
        headerView.backgroundColor =
            .systemGray
            .withAlphaComponent(.alphaForHeader)
        let titleLabel = UILabel(
            frame: CGRect(
                x: headerView.frame.origin.x + .cornerRadius,
                y: headerView.frame.origin.x,
                width: headerView.frame.width,
                height: headerView.frame.height
            ))
        titleLabel.text = "7-day forecast"
        headerView.addSubview(titleLabel)
        return headerView
    }
}
