import UIKit
import RxCocoa
import RxSwift
import CoreLocation

//MARK: - class
class DataSource {
    
    // MARK: let/var
    static let shared = DataSource()
    let recievedLocation = PublishRelay<CLLocation?>()
}
