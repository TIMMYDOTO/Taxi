//
//  WeakSet.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 10.10.2017.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import UIKit

class WeakSet<T>: NSObject {
    
    var count: Int {
        return weakStorage.count
    }
    
    var objects:[AnyObject] {
        return weakStorage.allObjects
    }
    
    private let weakStorage = NSHashTable<AnyObject>.weakObjects()
    
    func add(_ object: T) {
        weakStorage.add(object as AnyObject?)
    }
    
    func remove(_ object: T) {
        if self.contains(object) {
            weakStorage.remove(object as AnyObject?)
        }
    }
    
    func removeAllObjects() {
        weakStorage.removeAllObjects()
    }
    
    func contains(_ object: T) -> Bool {
        return weakStorage.contains(object as AnyObject?)
    }
    
}

