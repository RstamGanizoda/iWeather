import RxCocoa
import RxSwift
import Foundation
import CoreLocation

final class SearchCityViewModel {
    
    // MARK: let/var
    let disposeBag = DisposeBag()
    let geocoder = CLGeocoder()
    let dataSource = DataSource.shared
    let selectedCityViewControllerID = "SelectedCityViewController"
    var city: String?
    let typedCityText = PublishRelay<String?>()
    let searchButtonPressed = PublishRelay<Bool>()
    let selectedCityViewController = PublishRelay<UIViewController>()
    let alertRelay = PublishRelay<UIAlertController>()
    let dataSourceForFavorite = BehaviorRelay<[SavedCitiesTableViewCellModel]>(value: [])
    
    let deleteItem = PublishRelay<Int>()
    
    init(city: String?){
        self.city = city
    }
    
    func deleteRow(at index: Int){
        var currentDataSource = dataSourceForFavorite.value
            currentDataSource.remove(at: index)
            dataSourceForFavorite.accept(currentDataSource)
//        var allCities = AllCities.shared.cityArray
//        allCities?.remove(at: index)
    }
    
    func removeCity(at index: Int) {
        guard var cityArray = StorageManager.shared.getCity() else { return }
        cityArray.remove(at: index)
        UserDefaults.standard.set(cityArray, forKey: "cityKey")
    }
    // MARK: Navigation
    func dataSourceTable() {
        if let allSavedCities = StorageManager.shared.getCity() {
            let sortedData = allSavedCities.map {
                SavedCitiesTableViewCellModel(city: $0.city)
            }
            dataSourceForFavorite.accept(sortedData)
        }
    }
    
    func configureSearchButton() {
        searchButtonPressed.subscribe { event in
            guard let controller = UIStoryboard(
                name: "Main",
                bundle: nil)
                .instantiateViewController(withIdentifier: self.selectedCityViewControllerID) as? SelectedCityViewController else { return }
            self.selectedCityViewController.accept(controller)
        }.disposed(by: disposeBag)
    }
    
    // MARK: Functionality
    func getLocation() {
        typedCityText
            .subscribe { cityText in
                self.city = cityText
            }.disposed(by: disposeBag)
    }
    
    func checkTextField(){
        if city == nil || city == "" {
            self.createAlert()
        } else {
            self.geocoder.geocodeAddressString(city ?? "Cupertino") { placemark, _ in
                if let location = placemark?.first?.location {
                    self.dataSource.recievedLocation.accept(location)
                }
            }
        }
    }
    
    func createAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Please, enter the city name to find the weather",
            preferredStyle:
                    .alert
        )
        let cancel = UIAlertAction(
            title: "OK",
            style: .cancel
        )
        alert.addAction(cancel)
        self.alertRelay.accept(alert)
    }
}
