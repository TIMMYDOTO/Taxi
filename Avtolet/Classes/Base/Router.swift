//
//  Router.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 17.07.17.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import UIKit


protocol Router {
    
    var storyboard: UIStoryboard {get}
    var presenter: UIViewController? {get}
    
    init(presenter: UIViewController?)
    
}

extension Router {
    
    func show(_ viewController: UIViewController) {
        guard let presenter = presenter else {
            UIWindow.keyWindowTransitToViewController(viewController)
            return
        }
        presenter.firstParent().view.endEditing(true)
        presenter.show(viewController, sender: .none)
       
    }
    
    func set(_ viewController: UIViewController, animated: Bool = true) {
        if let navVC = presenter?.navigationController {
            presenter?.firstParent().view.endEditing(true)
            navVC.setViewControllers([viewController], animated: animated)
        } else {
            show(viewController)
        }
    }
    
    func presentModal(_ viewController: UIViewController, animated: Bool = true, completion: (() -> ())? = .none) {
        guard let presenter = presenter else {
            UIWindow.keyWindowTransitToViewController(viewController)
            return
        }
        presenter.present(viewController,
                                        animated: animated,
                                        completion: completion)
    }
    
    func presentChild(_ viewController: UIViewController, inViewController vc: UIViewController) {
        vc.addChildViewController(viewController)
        viewController.willMove(toParentViewController: vc)
        vc.view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: vc)
    }
    
}

extension UIViewController {
    func firstParent() -> UIViewController {
        if let parent = self.parent {
            return parent.firstParent()
        } else {
            return self
        }
    }
}

public extension UIWindow {
    
    class func keyWindowTransitToViewController(_ viewController: UIViewController) {
        UIApplication.shared.keyWindow?.transitToViewController(viewController)
    }
    
    func transitToViewController(_ viewController: UIViewController) {
        let currentSubviews = subviews
        insertSubview(viewController.view, belowSubview: rootViewController!.view)
        UIView.transition(with: self,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: { self.rootViewController = viewController },
                          completion: { finished in
                            currentSubviews.forEach({
                                if !($0 is UIImageView) {
                                    $0.removeFromSuperview()
                                }
                            })
        })
    }
    
}
