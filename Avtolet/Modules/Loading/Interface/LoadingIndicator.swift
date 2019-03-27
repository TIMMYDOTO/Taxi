//
//  LoadingIndicator.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/26/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class LoadingIndicator {
    
    private init() { }
    
    static let shared = LoadingIndicator()
    
    let activityIndicator = UIActivityIndicatorView()
    
    var overlay = UIView()
    
     func showActivity(viewController: UIViewController) {
  
        activityIndicator.center = viewController.view.center
        activityIndicator.startAnimating()
        activityIndicator.activityIndicatorViewStyle = .gray
        overlay.frame = UIScreen.main.bounds
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0.66
        viewController.view.addSubview(overlay)
        viewController.view.addSubview(activityIndicator)
    }
    
    
     func hideActivity(){
        overlay.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        
    }
    
}
