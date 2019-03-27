//
//  FindAddressDataSource.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 29.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class FindAddressDataSource: DataSource {
    
    var addresses = [SearchAddress]()
    
    var addressSelected: ((SearchAddress) -> ())?
    
    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
        let address = addresses[indexPath.row]
        return ElementConfigurator(reuseIdentifier: "SearchAddressCell") {
            guard let cell = $0 as? SearchAddressCell else { return }
            cell.setup(address: address)
        }
    }
    
    override func rowAction(_ indexPath: IndexPath) {
        tableView?.deselectRow(at: indexPath, animated: true)
        let address = addresses[indexPath.row]
        addressSelected?(address)
    }
    
    override func numberOfElementsInSection(_ section: Int) -> Int {
        return addresses.count
    }
    
    func update(addresses: [SearchAddress]) {
        self.addresses = addresses
        self.tableView?.reloadData()
    }
    
}
