//
//  AuthDatasource.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 26.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

enum AuthDatasourceState {
    case auth, confirmCode
}

fileprivate enum AuthCellType: String {
    case logo = "AuthLogoCell"
    case title = "AuthTitleCell"
    case textField = "AuthTextFieldCell"
    case button = "AuthButtonCell"
    case info = "AuthInfoCell"
    case codeTextField = "ConfirmCodeTextFieldCell"
    case anotherNumber = "ConfirmCodeAnotherNumberCell"
}

class AuthDatasource: DataSource {
    
    enum Constant {
        static let secondsToRetry = 120
    }
    
    fileprivate var cells = [AuthCellType]()
    fileprivate var state = AuthDatasourceState.auth
    
    var buttonTappedHandler: (() -> ())?
    var dogovorTappedHandler: (() -> ())?
    var anotherNumberHandler: (() -> ())?
    var retryHandler: (() -> ())?
    var codeAdded: ((String) -> ())?
    
    fileprivate weak var timer: Timer?
    fileprivate var seconds = Constant.secondsToRetry
    
    fileprivate(set) var phone = "" {
        didSet {
            phoneChanged()
        }
    }
    
    fileprivate(set) var code = "" {
        didSet {
            codeChanged()
        }
    }
    
    var isPhoneValid: Bool {
        return phone.count == 11
    }
    
    var isValidationMode = false
    fileprivate var canRepeatCode = false
    
    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
        let model = cells[indexPath.row]
        return ElementConfigurator(reuseIdentifier: model.rawValue) { [unowned self] in
            guard let cell = $0 as? UITableViewCell else { return }
            if let cell = cell as? AuthTitleCell {
                cell.setup(title: self.state == .auth ? "Номер телефона" : "Код подтверждения")
            } else if let cell = cell as? AuthTextFieldCell {
                cell.setup(placeholder: "+7 (XXX) XXX-XX-XX", isValidationMode: self.isValidationMode)
                cell.textFieldDidChange = { [weak self] textField in
                    guard let `self` = self else { return }
                    self.phone = textField.phoneNumber() ?? ""
                 }
            } else if let cell = cell as? AuthButtonCell {
                if self.state == .auth {
                    cell.setup(title: "Продолжить")
                    cell.buttonTappedHandler = { [weak self] in
                        self?.buttonTappedHandler?()
                    }
                } else {
                    cell.setupWithTimer(canRepeat: self.canRepeatCode)
                    cell.buttonTappedHandler = { [weak self] in
                        self?.retryHandler?()
                    }
                }
            } else if let cell = cell as? AuthInfoCell {
                let titleParagraphStyle = NSMutableParagraphStyle()
                titleParagraphStyle.alignment = .center
                let string = NSMutableAttributedString(string: "Ознакомьтесь с $$договором-офертой$$. Регистрируясь или авторизуясь в «Автолёт», вы принимаете его условия.", attributes: [NSAttributedStringKey.font: UIFont.cuprumFont(ofSize: 14.0), NSAttributedStringKey.foregroundColor: UIColor.text_grey, NSAttributedStringKey.paragraphStyle: titleParagraphStyle])
                string.addAttributes(attributes: [NSAttributedStringKey.link: "dogovor"], delimiter: "$$")
                cell.setup(info: string)
                cell.interactHandler = { [weak self] _ in
                    self?.dogovorTappedHandler?()
                }
            } else if let cell = cell as? ConfirmCodeTextFieldCell {
                cell.setup(placeholder: "****")
                cell.textFieldDidChange = { [weak self] string in
                    guard let `self` = self else { return }
                    self.code = string
                }
            } else if let cell = cell as? ConfirmCodeAnotherNumberCell {
                cell.setup(title: "Другой номер")
                cell.buttonHandler = { [weak self] in
                    guard let `self` = self else { return }
                    self.anotherNumberHandler?()
                }
            }
        }
    }
 
    override func numberOfElementsInSection(_ section: Int) -> Int {
        return cells.count
    }
    
    func update(state: AuthDatasourceState) {
        self.state = state
        cells = []
        cells.append(.logo)
        cells.append(.title)
        if state == .auth {
            cells.append(.textField)
            cells.append(.button)
            cells.append(.info)
        } else {
            cells.append(.codeTextField)
            cells.append(.button)
            cells.append(.anotherNumber)
        }
        tableView?.reloadData()
        if state == .confirmCode {
            canRepeatCode ? manageResentButton() : configureTimer() 
        }
    }
    
}

extension AuthDatasource {
    func phoneChanged() {
        isValidationMode = !isPhoneValid
        if isPhoneValid {
            tableView?.endEditing(true)
            tableView?.reloadData()
        }
    }
    func codeChanged() {
        if code.count == 0 || code.count == 4 {
            tableView?.endEditing(true)
        }
        if code.count == 4 {
            codeAdded?(code)
        }
    }
}

extension AuthDatasource {
    func configureTimer() {
        timer?.invalidate()
        timer = nil
        self.seconds = Constant.secondsToRetry
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        self.updateTimer()
    }
    
    @objc func updateTimer() {
        if seconds <= 0 {
            timer?.invalidate()
            timer = nil
            manageResentButton()
        } else {
            seconds -= 1
            let minutes = seconds/60
            let extraSectonds = seconds - minutes*60
            updateProgress(minutes: NumberFormatter.timerFormatter.string(from: minutes as NSNumber) ?? "", seconds: NumberFormatter.timerFormatter.string(from: extraSectonds as NSNumber) ?? "")
        }
    }
    
    func manageResentButton() {
        timer?.invalidate()
        timer = nil
        guard let cell = tableView?.cellForRow(at: IndexPath(row: 3, section: 0)) as? AuthButtonCell else { return }
        canRepeatCode = true
        cell.setupWithTimer(canRepeat: canRepeatCode)
        cell.button.setTitle("Повторить".uppercased(), for: .normal)
    }
    
    func updateProgress(minutes: String, seconds: String) {
        guard let cell = tableView?.cellForRow(at: IndexPath(row: 3, section: 0)) as? AuthButtonCell else { return }
        canRepeatCode = false
        UIView.setAnimationsEnabled(false)
        cell.setupWithTimer(canRepeat: canRepeatCode)
        cell.button.setTitle("\(minutes):\(seconds)", for: .normal)
        UIView.setAnimationsEnabled(true)
    }
    
}
