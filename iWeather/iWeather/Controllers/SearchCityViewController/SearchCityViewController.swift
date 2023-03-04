
import RxCocoa
import RxSwift
import UIKit

private extension CGFloat {
    static let space = 10.0
    static let cornerRadiusForInput = CGFloat(15)
    static let borderWidth = CGFloat(0.5)
    static let alphaForTextFieldBack = CGFloat(0.2)
    static let paddingWidth = CGFloat(10.0)
    static let rowHeigh = CGFloat(150.0)
}

private extension UIColor {
    static let borderColorForInput = UIColor.white.cgColor
}

class SearchCityViewController: UIViewController {

    //MARK: IBOutlet
    @IBOutlet weak var searchCityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var savedCitiesTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: let/var
    let disposeBag = DisposeBag()
    let viewModel = SearchCityViewModel(city: nil)
    let textFieldPlaceholder = "🔍 Search for a city"

    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        addAllUI()
        createAlert()
        viewModel.getLocation()
        addTapRecognizer()
        getTypedText()
        configureCurrentWeather()
        viewModel.dataSourceTable()
        moveToSelectedViewController()
        viewModel.deleteItem.subscribe { index in
            self.viewModel.deleteRow(at: index)
        }.disposed(by: disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    //MARK: IBAction
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        self.viewModel.checkTextField()
        self.viewModel.searchButtonPressed.accept(true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
    //MARK: Navigation
    private func moveToSelectedViewController() {
        viewModel.configureSearchButton()
        viewModel.selectedCityViewController.subscribe { event in
            self.present(event, animated: true)
        }.disposed(by: disposeBag )
    }
    
    //MARK: UI
    private func addAllUI(){
        modifyButtons()
        modifyTableView()
        modifySearchTextField()
    }
    private func modifySearchTextField() {
        let placeholderText = NSAttributedString(
            string: self.textFieldPlaceholder,
            attributes: [NSAttributedString
                .Key
                .foregroundColor: UIColor.white]
        )
        searchCityTextField.attributedPlaceholder = placeholderText
        searchCityTextField.clearButtonMode = .always
        searchCityTextField.clearsOnBeginEditing = true
        searchCityTextField.autocapitalizationType = .words
    
        searchCityTextField.layer.cornerRadius = .cornerRadiusForInput
        searchCityTextField.layer.borderWidth = .borderWidth
        searchCityTextField.layer.borderColor = UIColor.borderColorForInput
        let paddingView = UIView(
            frame: CGRect(
                x: searchCityTextField.frame.origin.x,
                y: searchCityTextField.frame.origin.y,
                width: .paddingWidth,
                height: searchCityTextField.frame.size.height
            )
        )
        searchCityTextField.leftView = paddingView
        searchCityTextField.leftViewMode = .always
        searchCityTextField.backgroundColor = .systemGray.withAlphaComponent(.alphaForTextFieldBack)
    }
    
    private func modifyTableView(){
        savedCitiesTableView.separatorStyle = .none
    }
    
    private func modifyButtons() {
        searchButton.layer.borderColor = UIColor.borderColorForInput
        searchButton.layer.borderWidth = .borderWidth
        searchButton.layer.cornerRadius = .cornerRadiusForInput
        backButton.layer.borderColor = UIColor.borderColorForInput
        backButton.layer.borderWidth = .borderWidth
        backButton.layer.cornerRadius = .cornerRadiusForInput
    }
    
    //MARK: Functionality
    private func createAlert() {
        viewModel.alertRelay.subscribe { event in
            self.present(event, animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func addTapRecognizer() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func registerNib(){
        self.savedCitiesTableView.register(UINib(nibName: "SavedCitiesTableViewCell", bundle: nil), forCellReuseIdentifier: "SavedCitiesTableViewCell")
    }
    
    private func getTypedText() {
        searchCityTextField.rx.controlEvent(.allEvents)
            .asObservable()
            .withLatestFrom(
                searchCityTextField
                    .rx
                    .text
                    .orEmpty
                    .asObservable()
            )
            .bind { [weak self] text in
                self?.viewModel.typedCityText.accept(text)
            }.disposed(by: disposeBag)
        self.searchCityTextField.delegate = self
    }
    
    private func configureCurrentWeather() {
        viewModel.dataSourceForFavorite.asObservable().bind(
            to: savedCitiesTableView.rx.items(
                cellIdentifier: SavedCitiesTableViewCell.identifier,
                cellType: SavedCitiesTableViewCell.self
            )
        ) { index, model, cell in
            cell.configureFavoriteCity(model, index)
        }.disposed(by: disposeBag)
        
        savedCitiesTableView.rx.itemDeleted.subscribe { [weak self] event in
            if let indexPath = event.element {
                self?.viewModel.deleteItem.accept(indexPath.row)
            }
        }.disposed(by: disposeBag)
        
        self.savedCitiesTableView.delegate = self
    }
}
//MARK: extensions
extension SearchCityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return .rowHeigh
    }
}

extension SearchCityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
