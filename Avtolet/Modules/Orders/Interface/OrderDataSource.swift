//
//  OrderDataSource.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 31.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

enum OrderCellType {
    case route, fromTitle, from, toTitle, to, descrTitle, descr, reasonTitle, reason, car, autoType, autoSize, performers, performer, priceTitle, totalPrice, priceDetails, button, rate, separator
    
    var reuseIdentifier: String {
        switch self {
        case .route, .car, .performers, .priceTitle:
            return "MainTitleCell"
        case .fromTitle, .toTitle, .descrTitle, .reasonTitle:
            return "AuthTitleCell"
        case .from, .to, .descr, .reason:
            return "MainRouteCell"
        case .autoType, .autoSize:
            return "OrderDoubleInfoCell"
        case .performer:
            return "OrderPerformerCell"
        case .totalPrice:
            return "OrderTotalPriceCellCell"
        case .priceDetails:
            return "RoundedCell"
        case .button:
            return "RegistrationButtonCell"
        case .rate:
            return "PerformerRatingCell"
        case .separator:
            return "SeparatorCell"
        }
    }
}

class OrderDataSource: DataSource {
    
    fileprivate var cells = [OrderCellType]()
    fileprivate var performers: [Int: OrderPerformer] = [:]
    
    var order: Order?
    var performer: OrderPerformer?
    var state = MyOrdersState.completed
    var buttonTapped: (() -> ())?
    var communicateHandler: ((OrderPerformer) -> ())?
    var canCancelOrder = true
    
    var rating: Int?
    
    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
        let model = cells[indexPath.row]
        return ElementConfigurator(reuseIdentifier: model.reuseIdentifier) { [unowned self] in
            guard let cell = $0 as? UITableViewCell else { return }
            cell.selectionStyle = .none
            if let cell = cell as? MainTitleCell {
                switch model {
                case .route:
                    cell.setup(title: "Маршрут")
                case .car:
                    cell.setup(title: "Автомобиль")
                case .performers:
                    cell.setup(title: self.performer != nil ? "Исполнитель" : "Исполнители")
                case .priceTitle:
                    cell.setup(title: "Стоимость поездки")
                    default:()
                }
            } else if let cell = cell as? AuthTitleCell {
                switch model {
                case .fromTitle:
                    cell.setup(title: "Пункт отправления")
                case .toTitle:
                    cell.setup(title: "Пункт назначения")
                case .descrTitle:
                    cell.setup(title: "Описание груза")
                case .reasonTitle:
                    cell.setup(title: "Причина отмены")
                default:()
                }
            } else if let cell = cell as? MainRouteCell {
                switch model {
                case .from:
                    cell.setup(title: self.order?.origin ?? self.order?.routeData?.origin ?? "")
                case .to:
                    cell.setup(title: self.order?.destination ?? self.order?.routeData?.destination ?? "")
                case .descr:
                    cell.setup(title: self.order?.cargoDescription ?? "")
                case .reason:
                    cell.setup(title: self.order?.reason ?? "")
                default:()
                }
            } else if let cell = cell as? OrderDoubleInfoCell {
                switch model {
                case .autoType:
                    guard let auto = self.order?.performers?.first?.performer?.auto else { return }
                    cell.setup(titles: ["Марка", "Гос. номер"], infos: [auto.model, auto.reg])
                case .autoSize:
                    guard let auto = self.order?.performers?.first?.performer?.auto else { return }
                    let font = UIFont.cuprumFont(ofSize: 18.0)
                    let firstInfo = auto.volume.volumeString(font: font)
                    let seconfInfo = NSAttributedString(string: auto.proportions.descriptionString, attributes: [NSAttributedStringKey.font: font])
                    cell.setup(titles: ["Объём", "Габариты (ДхШхВ)"], infos: [firstInfo, seconfInfo])
                    default:()
                }
            } else if let cell = cell as? OrderPerformerCell {
                if let performer = self.performer {
                    cell.setup(performer: performer, state: self.state)
                } else {
                    guard let performer = self.performers[indexPath.row] else  { return }
                    cell.setup(performer: performer, state: self.state)
                    cell.communicateHandler = { [weak self] in
                        self?.communicateHandler?($0)
                    }
                }
            } else if let cell = cell as? OrderTotalPriceCellCell {
                if let performer = self.performer {
                    cell.setup(totalPrice: performer.totalFee)
                } else {
                    guard let total = self.order?.totalPrice else { return }
                    cell.setup(totalPrice: total)
                }
            } else if let cell = cell as? RoundedCell {
                guard let fare = self.order?.fare ?? self.performer?.fare else { return }
                cell.setup(fare: fare)
            } else if let cell = cell as? RegistrationButtonCell {
                cell.setup(title: self.performer != nil ? "Готово" : "Отменить заказ")
                cell.buttonTappedHandler = { [weak self] in
                    self?.buttonTapped?()
                }
            } else if let cell = cell as? PerformerRatingCell {
                cell.setup(title: "Оцените работу исполнителя", rating: self.rating ?? 0)
                cell.ratingSelected = { [weak self] in
                    self?.rating = $0
                }
            } else if model == .separator {
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = .clear
            }
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func numberOfElementsInSection(_ section: Int) -> Int {
        return cells.count
    }
    
    func update(order: Order) {
        self.order = order
        fillCells()
        self.tableView?.reloadData()
    }
    
    func update(performer: OrderPerformer) {
        self.performer = performer
        fillPerformerCells()
        self.tableView?.reloadData()
    }
    
    func fillPerformerCells() {
        var cells = [OrderCellType]()
        cells.append(.totalPrice)
        if let fare = self.performer?.fare, fare.count > 0 {
            cells.append(.separator)
            cells.append(.priceDetails)
        }
        cells.append(.performers)
        cells.append(.performer)
        cells.append(.rate)
        cells.append(.button)
        self.cells = cells
    }
    
    func fillCells() {
        var cells = [OrderCellType]()
        var performers: [Int: OrderPerformer] = [:]
        if let order = self.order {
            //Отменённый заказ
            if state == .canceled {
                cells.append(.route)
                if order.origin != nil {
                    cells.append(.fromTitle)
                    cells.append(.from)
                }
                if order.destination != nil {
                    cells.append(.toTitle)
                    cells.append(.to)
                }
                if order.cargoDescription != nil {
                    cells.append(.descrTitle)
                    cells.append(.descr)
                }
                if order.reason != nil {
                    cells.append(.reasonTitle)
                    cells.append(.reason)
                }
            } else
            //Завершенный или активный заказ
            if state == .completed || state == .active {
                cells.append(.route)
                if order.routeData?.origin != nil || order.origin != nil {
                    cells.append(.fromTitle)
                    cells.append(.from)
                }
                if order.routeData?.destination != nil || order.destination != nil {
                    cells.append(.toTitle)
                    cells.append(.to)
                }
                if order.cargoDescription != nil {
                    cells.append(.descrTitle)
                    cells.append(.descr)
                }
                if order.performers?.filter({ $0.performer != nil && $0.performer?.auto != nil }).first?.performer?.auto != nil {
                    cells.append(.car)
                    cells.append(.autoType)
                    cells.append(.autoSize)
                }
                if let operformers = order.performers?.filter({ $0.performer != nil }), operformers.count > 0 {
                    cells.append(.performers)
                    for performer in operformers {
                        cells.append(.performer)
                        performers[cells.count-1] = performer
                    }
                }
                if state != .active {
                    cells.append(.priceTitle)
                    if self.order?.totalPrice != nil {
                        cells.append(.totalPrice)
                    }
                    if let fare = self.order?.fare, fare.count > 0 {
                        cells.append(.priceDetails)
                    }
                } else {
                    if canCancelOrder {
                        cells.append(.button)
                    } else {
                        var insets = tableView?.contentInset ?? UIEdgeInsets.zero
                        insets.bottom = 70.0
                        tableView?.contentInset = insets
                    }
                }
            }
        }
        self.cells = cells
        self.performers = performers
    }
    
}
