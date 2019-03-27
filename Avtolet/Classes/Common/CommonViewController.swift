//
//  CommonViewController.swift
//  MusicAssistant
//
//  Created by Igor Tyukavkin on 21.10.2017.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import UIKit
import SVProgressHUD

class CommonViewController: UIViewController {
    
    // MARK:  - Keyboard binding
    fileprivate var constraintToBindKeyboard: NSLayoutConstraint?
    fileprivate var scrollViewToBindKeyboard: UIScrollView?
    fileprivate var constant: CGFloat = 0.0
    fileprivate var inverted: Bool = false
    fileprivate var insets: UIEdgeInsets = UIEdgeInsets.zero
    
  
    
    func handleError(_ error: RCError) {
        showAlert(message: kDefaultErrorMessage)
    }
    
    func showHUD() {
        SVProgressHUD.show()
    }
    
    func hideHUD() {
        SVProgressHUD.dismiss()
    }
    
}
//MARK: - Keyboard
extension CommonViewController {
    
    func bindScrollViewToKeyboard(_ scrollView: UIScrollView) {
        scrollViewToBindKeyboard = scrollView
        self.insets = scrollView.contentInset
        addKeyboardObservers()
    }
    
    func unbindScrollViewtoKeyboard(_ scrollView: UIScrollView) {
        scrollViewToBindKeyboard = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func bindConstraintToKeyboard(_ constraint: NSLayoutConstraint, constant: CGFloat = 0.0, inverted: Bool = false) {
        constraintToBindKeyboard = constraint
        self.constant = constant
        self.inverted = inverted
        addKeyboardObservers()
    }
}

//MARK: - Notifications
extension CommonViewController {
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc  func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            constraintToBindKeyboard?.constant = inverted ? -keyboardSize.height : keyboardSize.height
            let time = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double)
            if scrollViewToBindKeyboard != nil {
                let targetInset =  UIEdgeInsets(top: self.insets.top, left: self.insets.left, bottom: self.insets.bottom + keyboardSize.height, right: self.insets.right)
                self.scrollViewToBindKeyboard?.contentInset = targetInset
            }
            UIView.animate(withDuration: time ?? 0.23, animations: { [unowned self] in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc  func keyboardWillHide(notification: NSNotification) {
        let time = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double)
        constraintToBindKeyboard?.constant = constant
        if scrollViewToBindKeyboard != nil {
            let targetInset = self.insets
            self.scrollViewToBindKeyboard?.contentInset = targetInset
        }
        UIView.animate(withDuration: time ?? 0.23, animations: { [unowned self] in
            self.view.layoutIfNeeded()
        })
    }
}

//MARK: - Errors
extension CommonViewController {
    func showAlert(title: String = "", message: String, buttons: [String] = [], cancelButtonIndex: Int = 0, handler: ((Int) -> ())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.view.tintColor = UIColor.blue_main
        if buttons.count > 0 {
            for i in 0..<buttons.count {
                let action = UIAlertAction(title: buttons[i], style: i == cancelButtonIndex ? .cancel : .default) { _ in
                    handler?(i)
                }
                alertController.addAction(action)
            }
        } else {
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(okAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
}
