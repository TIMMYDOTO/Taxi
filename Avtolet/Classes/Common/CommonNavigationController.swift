//
//  CommonNavigationController.swift
//  MusicAssistant
//
//  Created by Igor Tyukavkin on 21.10.2017.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import UIKit

class CommonNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back-icon")
        self.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back-icon")
        
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        navigationBar.barTintColor = UIColor.navBar_blue
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                             NSAttributedStringKey.font: UIFont.cuprumFont(ofSize: 20.0)]
    }
    
}

extension UINavigationItem {
    func removeBackButtonTitle() {
        self.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target:nil, action:nil)
    }
}
