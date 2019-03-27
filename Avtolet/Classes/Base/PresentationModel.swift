//
//  PresentationModel.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 09.08.17.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import Foundation

class PresentationModel: NSObject {
    
    typealias ErrorHandler = (RCError) -> ()
    typealias LoadingHandler = (Bool) -> ()
    
    fileprivate(set) var isLoading: Bool = false
    
    var errorHandler: ErrorHandler?
    fileprivate var _loadingHandler: LoadingHandler?
    var loadingHandler: LoadingHandler? {
        set {
            _loadingHandler = newValue
        }
        get {
            return loading
        }
    }
    
    required init(errorHandler: ErrorHandler?) {
        super.init()
        self.errorHandler = errorHandler
    }
    
    fileprivate func loading(_ isLoading: Bool) {
        self.isLoading = isLoading
        _loadingHandler?(isLoading)
    }
    
}
