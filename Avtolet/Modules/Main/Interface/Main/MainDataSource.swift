//
//  MainDataSource.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

enum MainCellType {
    case routeTitle, carsTitle, carTitle, carFrameTitle, carCollection, carFrameCollection, fromTitle, toTitle, fromRoute, toRoute, descriptionTitle, description, optionsTitle, options, services, loadersTitle, loaders, price, button, promocodeTitle, promocode
    
    var reuseIdentifier: String {
        switch self {
        case .routeTitle, .carsTitle, .optionsTitle:
            return "MainTitleCell"
        case .carTitle, .carFrameTitle, .fromTitle, .toTitle, .services, .loadersTitle, .descriptionTitle, .promocodeTitle:
            return "AuthTitleCell"
        case .carCollection, .carFrameCollection, .loaders:
            return "MainCollectionTableViewCell"
        case .fromRoute, .toRoute:
            return "MainRouteCell"
        case .description:
            return "MainDescriptionCell"
        case .options:
            return "MainOptionsCell"
        case .price:
            return "MainPriceCell"
        case .button:
            return "RegistrationButtonCell"
        case .promocode:
            return "MainPromocodeCell"
        }
    }
    
}

class MainDataSource: DataSource {
    
    var cells = [MainCellType]()
    var cars = [Car]()
    
    var fromRouteSelected: (() -> ())?
    var toRouteSelected: (() -> ())?
    var buttonTapped: (() -> ())?
    var recalculateHandler: (() -> ())?
    var applyPromocodeHandler: ((String) -> ())?
    
    var selectedOptions: [Int] = [] { didSet { recalculateHandler?() } }
    var selectedCar: Int? { didSet { recalculateHandler?() } }
    var selectedCarFrame: Int? {
        didSet {
            if needRecalculate {
                recalculateHandler?()
            }
            needRecalculate = true
        }
    }
    var querySelectedCarFrame: Int?
    var fromRoute: SearchAddress? { didSet { recalculateHandler?() } }
    var toRoute: SearchAddress? { didSet { recalculateHandler?() } }
    var loaders: Int = 0 { didSet { recalculateHandler?() } }
    var promocode: String? {
        didSet {
            promocodeDraft = nil
            tableView?.reloadData()
        }
    }
    var promocodeDraft: String?
    var promocodeId: Int? { didSet { recalculateHandler?() } }
    
    var descr: String = ""
    var route: Route? {
        didSet {
            if route != nil {
                recalculateHandler?()
            }
        }
    }
    var minPrice = 0.0
    
    var needRecalculate = true
    
    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
        let model = cells[indexPath.row]
        return ElementConfigurator(reuseIdentifier: model.reuseIdentifier) { [unowned self] in
            guard let cell = $0 as? UITableViewCell else { return }
            cell.selectionStyle = .none
            if let cell = cell as? MainTitleCell {
                switch model {
                    case .routeTitle:
                        cell.setup(title: "Маршрут")
                    case .carsTitle:
                        cell.setup(title: "Автомобиль")
                    case .optionsTitle:
                        cell.setup(title: "Дополнительные опции")
                    default:()
                }
            } else if let cell = cell as? AuthTitleCell {
                switch model {
                case .carTitle:
                    cell.setup(title: "Категория")
                case .carFrameTitle:
                    cell.setup(title: "Кузов")
                case .fromTitle:
                    cell.setup(title: "Пункт отправления")
                case .toTitle:
                    cell.setup(title: "Пункт назначения")
                case .services:
                    cell.setup(title: "Услуги")
                case .loadersTitle:
                    cell.setup(title: "Кол-во грузчиков")
                case .descriptionTitle:
                    cell.setup(title: "Описание груза")
                case .promocodeTitle:
                    cell.setup(title: "Промокод (если есть)")
                default:()
                }
            } else if let cell = cell as? MainCollectionTableViewCell {
                guard let selectedCar = self.selectedCar else { return }
                switch model {
                case .carCollection:
                    cell.update(cars: self.cars, selectedCar: selectedCar)
                    cell.modelSelected = { [weak self] selectedCar in
                        guard let `self` = self else { return }
                        self.needRecalculate = false
                        self.selectedCarFrame = -1
                        self.querySelectedCarFrame = self.cars.filter({ $0.id == selectedCar }).first?.frames.first?.id
                        self.tableView?.reloadData()
                        self.selectedCar = selectedCar
                    }
                case .carFrameCollection:
                    cell.update(frames: self.cars.filter({ $0.id == selectedCar }).first?.frames ?? [], selectedFrame: self.selectedCarFrame ?? -1)
                    cell.modelSelected = { [weak self] in
                        guard let `self` = self else { return }
                        guard let selectedCar = self.selectedCar else { return }
                        if $0 == -1 {
                            self.querySelectedCarFrame = self.cars.filter({ $0.id == selectedCar }).first?.frames.first?.id
                        } else {
                            self.querySelectedCarFrame = $0
                        }
                        self.selectedCarFrame = $0
                    }
                case .loaders:
                    cell.update(loadersCount: 5, selectedLoaders: self.loaders)
                    cell.modelSelected = { [weak self] in
                        self?.loaders = $0
                    }
                default:()
                }
            } else if let cell = cell as? MainRouteCell {
                switch model {
                case .fromRoute:
                    cell.setup(title: self.fromRoute?.address ?? "Выбрать адрес")
                case .toRoute:
                    cell.setup(title: self.toRoute?.address ?? "Выбрать адрес")
                default:()
                }
            } else if let cell = cell as? MainDescriptionCell {
                cell.setup(placeholder: "Нажмите для ввода текста")
                cell.update(value: self.descr)
                cell.valueChanged = { [weak self] value in
                    self?.descr = value
                    self?.tableView?.beginUpdates()
                    self?.tableView?.endUpdates()
                }
            } else if let cell = cell as? MainOptionsCell {
                cell.setup(options: [("Вывоз мусора", 1),("Экспедирование",2)], selectedOptions: self.selectedOptions)
                cell.optionSelected = { [weak self] option in
                    guard let `self` = self else { return }
                    if let index = self.selectedOptions.index(where: { $0 == option }) {
                        self.selectedOptions.remove(at: index)
                    } else {
                        self.selectedOptions.append(option)
                    }
                }
            } else if let cell = cell as? MainPriceCell {
                cell.setup(title: "Минимальная стоимость ≈ ", price: self.minPrice)
            } else if let cell = cell as? RegistrationButtonCell {
                cell.setup(title: "Заказать")
                cell.buttonTappedHandler = { [weak self] in
                    self?.buttonTapped?()
                }
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = .clear
            } else if let cell = cell as? MainPromocodeCell {
                cell.setup(promocode: self.promocode, draft: self.promocodeDraft)
                cell.applyPromocodeHandler = { [weak self] in
                    self?.applyPromocodeHandler?($0.trim())
                }
                cell.textDidChangeHandler = { [weak self] in
                    self?.promocodeDraft = $0?.trim()
                }
            }
        }
    }
    
    override func rowAction(_ indexPath: IndexPath) {
        tableView?.deselectRow(at: indexPath, animated: true)
        let model = cells[indexPath.row]
        if model == .fromRoute {
            fromRouteSelected?()
        } else if model == .toRoute {
            toRouteSelected?()
        }
    }
    
    override func numberOfElementsInSection(_ section: Int) -> Int {
        return cells.count
    }
    
    func update(cars: [Car]) {
        self.cars = cars
        if selectedCar == nil && selectedCarFrame == nil {
            selectedCar = cars.first?.id
            selectedCarFrame = -1
            querySelectedCarFrame = cars.first?.frames.first?.id
        }
        cells = [.routeTitle, .fromTitle, .fromRoute, .toTitle, .toRoute, .descriptionTitle, .description, .carsTitle, .carTitle, .carCollection, .carFrameTitle, .carFrameCollection, .optionsTitle, .services, .options, .loadersTitle, .loaders, .promocodeTitle, .promocode, .price, .button]
        tableView?.reloadData()
    }
    
}

extension MainDataSource {

    func updateFromAddress(address: SearchAddress) {
        route = nil
        minPrice = 0.0
        fromRoute = address
        self.tableView?.reloadData()
    }
    
    func updateToAddress(address: SearchAddress) {
        route = nil
        minPrice = 0.0
        toRoute = address
        self.tableView?.reloadData()
    }
    
    func updatePrice(price: Double) {
        self.minPrice = price
        guard let index = self.cells.index(where: { $0 == .price }),
              tableView?.cellForRow(at: IndexPath(row: index, section: 0)) != nil else { return }
        tableView?.reloadData()
    }
    
}
