////
////  TariffCollectionDatasource.swift
////  Avtolet
////
////  Created by Igor Tyukavkin on 27.03.2018.
////  Copyright © 2018 Igor Tyukavkin. All rights reserved.
////
//
//import UIKit
//
//class TariffCollectionDatasource: DataSource {
//
//    var tariffs: [Tariff] = []
//    var selectedTariffId: Int = 0
//    
//    var tariffSelected: ((Tariff) -> ())?
//    
//    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
//        let tariff = tariffs[indexPath.row]
//        return ElementConfigurator(reuseIdentifier: "TariffColectionCell") { [unowned self] in
//            guard let cell = $0 as? TariffColectionCell else { return }
//            cell.setup(title: tariff.name, isSelected: tariff.id == self.selectedTariffId)
//        }
//    }
//    
//    override func rowAction(_ indexPath: IndexPath) {
//        let tariff = tariffs[indexPath.row]
//        guard selectedTariffId != tariff.id else { return }
//        selectedTariffId = tariff.id
//        tariffSelected?(tariff)
//        collectionView?.reloadData()
//        collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
//    }
//    
//    override func numberOfElementsInSection(_ section: Int) -> Int {
//        return tariffs.count
//    }
//    
//    override func sizeForItem(_ indexPath: IndexPath) -> CGSize {
//        let tariff = tariffs[indexPath.row]
//        return CGSize(width: TariffColectionCell.width(title: tariff.name), height: TariffColectionCell.defaultHeight)
//    }
//    
//    func update(tariffs: [Tariff]) {
//        self.tariffs = tariffs
//        selectedTariffId = selectedTariffId == 0 ? tariffs.first?.id ?? 0 : selectedTariffId
//        collectionView?.reloadData()
//    }
//    
//}
