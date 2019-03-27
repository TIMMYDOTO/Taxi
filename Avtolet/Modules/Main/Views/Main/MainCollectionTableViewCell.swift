//
//  MainCollectionTableViewCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 29.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class MainCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        willSet {
            newValue.register(nib: TariffColectionCell.self)
            newValue.backgroundColor = .clear
        }
    }
    
    fileprivate lazy var datasource: MainCollectionDataSource = { [unowned self] in
        let datasource = MainCollectionDataSource(collectionView: self.collectionView)
        return datasource
    }()

    var modelSelected: ((Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func update(cars: [Car], selectedCar: Int) {
        updateDataSource(models: cars.map({ ($0.name, $0.id) }), selectedModel: selectedCar)
    }
    
    func update(frames: [CarFrame], selectedFrame: Int) {
        var frames = frames
        frames.insert(CarFrame(id: -1, name: "Любой"), at: 0)
        updateDataSource(models: frames.map({ ($0.name, $0.id) }), selectedModel: selectedFrame)
    }
    
    func update(loadersCount: Int, selectedLoaders: Int) {
        var models = [(String, Int)]()
        var index = 0
        while index <= loadersCount {
            models.append((String.loadersString(count: index), index))
            index += 1
        }
        updateDataSource(models: models, selectedModel: selectedLoaders)
    }
    
    fileprivate func updateDataSource(models: [(String, Int)], selectedModel: Int) {
        datasource.modelSelected = { [weak self] in
            self?.modelSelected?($0)
        }
        datasource.update(models: models, selectedModel: selectedModel)
    }
    
}
