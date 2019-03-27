////
////  TariffDatasource.swift
////  Avtolet
////
////  Created by Igor Tyukavkin on 27.03.2018.
////  Copyright © 2018 Igor Tyukavkin. All rights reserved.
////
//
//import UIKit
//
//class TariffDatasource: DataSource {
//
//    var tariff: Tariff?
//
//    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
//        let plan = tariff!.plans[indexPath.row]
//        return ElementConfigurator(reuseIdentifier: "RoundedCell") {
//            guard let cell = $0 as? RoundedCell else { return }
//            cell.setup(plan: plan)
//        }
//    }
//
//    override func numberOfElementsInSection(_ section: Int) -> Int {
//        return tariff?.plans.count ?? 0
//    }
//
//    func update(tariff: Tariff?) {
//        self.tariff = tariff
//        tableView?.reloadData()
//    }
//
//}
