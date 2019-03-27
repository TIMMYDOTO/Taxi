//
//  RegistrationDataSource.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

enum RegistrationCellType {
    case bigTitle, title, nameField, secondTitle, emailField, button
    
    var reuseIdentifier: String {
        switch self {
        case .bigTitle:
            return "RegistrationBigTitleCell"
        case .title, .secondTitle:
            return "RegistrationTitleCell"
        case .nameField, .emailField:
            return "RegistrationTextFieldCell"
        case .button:
            return "RegistrationButtonCell"
        }
    }
    
}

class RegistrationDataSource: DataSource {

    var cells = [RegistrationCellType]()
    
    var name = ""
    var email = ""
    var nameValid: Bool {
        return name.count >= 2
    }
    var emailValid: Bool {
        return validateEmail(email)
    }
    
    var buttonTappedHandler: (() -> ())?
    
    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
        let model = cells[indexPath.row]
        return ElementConfigurator(reuseIdentifier: model.reuseIdentifier) { [unowned self] in
            guard let cell = $0 as? UITableViewCell else { return }
            if let cell = cell as? RegistrationBigTitleCell {
                cell.setup(title: "Информация о себе")
            } else if let cell = cell as? RegistrationTitleCell {
                cell.setup(title: model == .title ? "Имя" : "Электронная почта")
            } else if let cell = cell as? RegistrationTextFieldCell {
                cell.setup(placeholder: model == .nameField ? "Иван" : "email@mail.ru", type: model == .nameField ? .name : .email)
                cell.textFieldDidChange = { [weak self] in
                    self?.textFieldDidChange(value: $0, type: model)
                }
            } else if let cell = cell as? RegistrationButtonCell {
                cell.setup(title: "Продолжить")
                cell.buttonTappedHandler = { [weak self] in
                    self?.buttonTappedHandler?()
                }
            }
        }
    }
    
    override func numberOfElementsInSection(_ section: Int) -> Int {
        return cells.count
    }
    
    func update() {
        cells = [.bigTitle, .title, .nameField, .secondTitle, .emailField, .button]
        tableView?.reloadData()
    }
    
    func textFieldDidChange(value: String, type: RegistrationCellType) {
        if type == .nameField {
            name = value.trim()
            if nameValid {
                highlightCell(type: RegistrationCellType.nameField, need: false)
            }
        } else {
            email = value.trim()
            if emailValid {
                highlightCell(type: RegistrationCellType.emailField, need: false)
            }
        }
    }
    
    func highlightCell(type: RegistrationCellType, need: Bool) {
        guard
            let index = cells.index(where: { $0 == type }),
            let cell = tableView?.cellForRow(at: IndexPath(row: index, section: 0)) as? RegistrationTextFieldCell else { return }
        cell.highlight(need)
    }
    
    func validationMode() {
        highlightCell(type: RegistrationCellType.nameField, need: !nameValid)
        highlightCell(type: RegistrationCellType.emailField, need: !emailValid)
    }
    
    func validateEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
}
