//
//  MainCollectionDataSource.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 29.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class MainCollectionDataSource: DataSource {

    var models = [(String, Int)]()
    var selectedModel = 0
    var modelSelected: ((Int) -> ())?
    
    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
        let model = models[indexPath.row]
        return ElementConfigurator(reuseIdentifier: "TariffColectionCell") { [unowned self] in
            guard let cell = $0 as? TariffColectionCell else { return }
            cell.setup(title: model.0, isSelected: model.1 == self.selectedModel)
        }
    }
    
    override func rowAction(_ indexPath: IndexPath) {
        let model = models[indexPath.row]
        guard selectedModel != model.1 else { return }
        selectedModel = model.1
        modelSelected?(model.1)
        collectionView?.reloadData()
        collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    override func numberOfElementsInSection(_ section: Int) -> Int {
        return models.count
    }
    
    override func sizeForItem(_ indexPath: IndexPath) -> CGSize {
        let model = models[indexPath.row]
        return CGSize(width: TariffColectionCell.width(title: model.0), height: TariffColectionCell.defaultHeight)
    }
    
    func update(models: [(String, Int)], selectedModel: Int) {
        self.models = models
        self.selectedModel = selectedModel
        collectionView?.reloadData()
    }
    
}
