import UIKit
import CoreLocation
import RxCocoa
import RxSwift

//MARK: - extension
private extension CGFloat {
    static let space = 10.0
    static let cornerRadius = CGFloat(20)
    static let heightOfRows = CGFloat(60)
    static let heightForHeader = CGFloat(30)
    static let alphaForBackground = CGFloat(0.15)
    static let alphaForHeader = CGFloat(0.95)
    static let widthOfCollections = CGFloat(60)
}

class CurrentWeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets
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
    
    // MARK: - let/var
    let viewModel = CurrentWeatherViewModel()
    let locationManager = CLLocationManager()
    var weatherData = Weather()
    let getAllWeather = WeatherManager.shared
    let disposeBag = DisposeBag()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addIcons()
        modifyHourlyCollectionView()
        modifyDailyTableView()
        bindCurrentWeather()
        bindCityName()
        configureDailyForecast()
        configureHourlyForecast()
        viewModel.configureSearchButton()
        moveToSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - IBAction
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        viewModel.searchButtonPressed.accept(true)
    }
    
    //MARK: - Navigation
    private func moveToSearchController() {
        viewModel.searchViewController.subscribe { event in
            self.navigationController?.pushViewController(event, animated: true)
        }.disposed(by: disposeBag)
    }
    
    // MARK: - UI
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
    
    // MARK: - Functionality
    private func bindCurrentWeather() {
        viewModel.fetchWeather()
        viewModel.currentTemp.subscribe { currentTemp in
            self.currentTempLabel.text = currentTemp
        }.disposed(by: disposeBag)
        
        viewModel.cloudsStatus.subscribe { cloudsStatus in
            self.cloudsStatusLabel.text = cloudsStatus
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
        
        viewModel.backgroundImage.subscribe { image in
            self.backgroundImageView.contentMode = .scaleAspectFill
            self.backgroundImageView.image = image
        }.disposed(by: disposeBag)
    }
    
    private func bindCityName() {
        viewModel.cityName.subscribe { city in
            self.cityLabel.text = city
        }.disposed(by: disposeBag)
    }
    
    private func configureHourlyForecast() {
        viewModel.dataSourceHourlyForecast.bind(
            to: hourlyCollectionView.rx.items(
                cellIdentifier: HourlyCollectionViewCell.identifier,
                cellType: HourlyCollectionViewCell.self
            )
        ) { index, model, cell in
            cell.configureForecast(model, index)
        }.disposed(by: disposeBag)
    }
    
    private func configureDailyForecast(){
        viewModel.dataSourceDailyForecast.bind(
            to: dailyTableView.rx.items(
                cellIdentifier: DailyTableViewCell.identifier,
                cellType: DailyTableViewCell.self
            )
        ) { index, model, cell in
            cell.configureDailyForecast(model, index)
        }.disposed(by: disposeBag)
        self.dailyTableView.delegate = self
    }
}

//MARK: - extensions
extension CurrentWeatherViewController: UITableViewDelegate {
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
