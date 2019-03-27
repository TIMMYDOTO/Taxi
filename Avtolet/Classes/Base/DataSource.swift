//
//  Datasource.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 17.08.17.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import UIKit

protocol DataSourceConvertable {}
typealias ReuseIdentifier = String
typealias ConfigurationBlock = (DataSourceConvertable) -> ()

struct ElementConfigurator {
    let reuseIdentifier: ReuseIdentifier
    let configurationBlock: ConfigurationBlock?
}

class DataSource: NSObject {
    
    fileprivate(set) weak var tableView: UITableView? {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }
    
    fileprivate(set) weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.delegate = self
            collectionView?.dataSource = self
        }
    }
    
    required init(tableView: UITableView) {
        defer { self.tableView = tableView }
        super.init()
    }
    
    
    required init(collectionView: UICollectionView) {
        defer { self.collectionView = collectionView }
        super.init()
    }
    
    //MARK: - For TableView Cells & CollectionView Items
    func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
        fatalError("You should ovveride method `configurator`")
    }
    
    //MARK: - CollectionView Supplementary views
    func supplementaryConfigurator(_ kind: String, indexPath: IndexPath) -> ElementConfigurator {
        fatalError("You should ovveride method `supplementaryConfigurator`")
    }
    
    func rowAction(_ indexPath: IndexPath) {
        
    }
    
    //MARK: Presets (override methods)
    func numberOfSections() -> Int { return 1 }
    func numberOfElementsInSection(_ section: Int) -> Int { return 0 }
    
    //MARK: TableView Presets
    func heightForRow(_ indexPath: IndexPath) -> CGFloat { return UITableViewAutomaticDimension }
    
    //MARK: CollectionView Presets
    func sizeForItem(_ indexPath: IndexPath) -> CGSize { return collectionView?.bounds.size ?? CGSize.zero }
}

//MARK: TableView DataSource/Delegate

extension DataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfElementsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configurator = self.configurator(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: configurator.reuseIdentifier, for: indexPath)
        configurator.configurationBlock?(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowAction(indexPath)
    }
}

//MARK: CollectionView

extension DataSource: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfElementsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let configurator = self.configurator(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configurator.reuseIdentifier, for: indexPath)
        configurator.configurationBlock?(cell)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryConfigurator = self.supplementaryConfigurator(kind, indexPath: indexPath)
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: supplementaryConfigurator.reuseIdentifier,
                                                                   for: indexPath)
        supplementaryConfigurator.configurationBlock?(view)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItem(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        rowAction(indexPath)
    }
}

extension UITableViewCell: DataSourceConvertable {}
extension UICollectionReusableView: DataSourceConvertable {}
