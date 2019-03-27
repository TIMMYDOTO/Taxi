//
//  MyOrdersDatasource.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 31.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

enum MyOrdersState: Int {
    case completed = 1, canceled = 2, active = 3, review = 4
}

class MyOrdersDatasource: DataSource {

    fileprivate(set) var state = MyOrdersState.completed
    fileprivate(set) var completedOrders: [ShortOrder]?
    fileprivate(set) var canceledOrders: [ShortOrder]?
    
    var orderSelected: ((ShortOrder) -> ())?
    
    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
        let model = state == .completed ? completedOrders![indexPath.row] : canceledOrders![indexPath.row]
        return ElementConfigurator(reuseIdentifier: "RoundedCell") { [unowned self] in
            guard let cell = $0 as? RoundedCell else { return }
            cell.setup(shortOrder  : model, isCanceled: self.state == .canceled)
        }
    }
    
    override func rowAction(_ indexPath: IndexPath) {
        tableView?.deselectRow(at: indexPath, animated: true)
        let model = state == .completed ? completedOrders![indexPath.row] : canceledOrders![indexPath.row]
        orderSelected?(model)
    }
    
    override func numberOfElementsInSection(_ section: Int) -> Int {
        let count = state == .completed ? completedOrders?.count ?? 0 : canceledOrders?.count ?? 0
        if count > 0 {
            tableView?.backgroundView = nil
        } else {
            tableView?.backgroundView = {
                let label = UILabel()
                label.font = UIFont.cuprumFont(ofSize: 18.0)
                label.textColor = UIColor.text_grey
                label.textAlignment = .center
                label.numberOfLines = 0
                label.text = "Недостаточно информации\n\n"
                return label
            }()
        }
        return count
    }
    
    func update(orders: OrdersResponse) {
        completedOrders = orders.completedOrders
        canceledOrders =  orders.canceledOrders
        tableView?.reloadData()
    }
    
    func changeState(state: MyOrdersState) {
        self.state = state
        tableView?.reloadData()
    }
    
}
