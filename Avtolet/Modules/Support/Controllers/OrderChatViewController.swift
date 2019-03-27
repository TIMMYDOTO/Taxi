//
//  ChatChatViewController.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 03/04/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import MaterialActivityIndicator
import RSKGrowingTextView

class OrderChatViewController: CommonViewController {

    @IBOutlet weak var tableView: UITableView! {
        willSet {
            newValue.tableFooterView = UIView()
            newValue.estimatedRowHeight = 60.0
            newValue.rowHeight = UITableViewAutomaticDimension
            newValue.backgroundColor = .clear
            let targetInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: ceil(chatTextView.frame.height) + 50.0 + bottomInset, right: 0.0)
            newValue.contentInset = targetInset
        }
    }
    
    fileprivate lazy var presentationModel: ChatPresentationModel = { [unowned self] in
        let model = ChatPresentationModel(performer: self.performer) { [weak self] in
            self?.handleError($0)
        }
        model.loadingHandler = { [weak self] in
            $0 ? self?.showHUD() : self?.hideHUD()
        }
        return model
    }()
    
    fileprivate lazy var datasource: OrderChatDataSource = { [unowned self] in
        let datasource = OrderChatDataSource(tableView: self.tableView)
        return datasource
    }()

    @IBOutlet weak var chatInputViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var chatInputView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 20.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.border_color_main.cgColor
            newValue.backgroundColor = .white
        }
    }
    @IBOutlet weak var chatTextView: RSKGrowingTextView! {
        willSet {
            newValue.resetStyles()
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.textAlignment = .left
            newValue.tintColor = .text_grey
            newValue.textColor = placeholderColor
            newValue.delegate = self
            newValue.text = placeholder
            newValue.returnKeyType = .send
            newValue.maximumNumberOfLines = 4
        }
    }
    @IBOutlet weak var chatButton: UIButton! {
        willSet {
            newValue.setImage(#imageLiteral(resourceName: "icon-send-message").changeColor(color: UIColor.blue_main), for: .normal)
            newValue.setImage(#imageLiteral(resourceName: "icon-send-message").changeColor(color: UIColor.blue_main), for: .highlighted)
            newValue.setImage(#imageLiteral(resourceName: "icon-send-message").changeColor(color: UIColor.border_color_main), for: .disabled)
            newValue.isEnabled = false
        }
    }
    @IBOutlet weak var chatIndicator: MaterialActivityIndicatorView! {
        willSet {
            newValue.isHidden = true
            newValue.color = .blue_main
            newValue.backgroundColor = .clear
        }
    }
    
    let placeholderColor = UIColor.border_color_main
    let placeholder = "Введите сообщение"
    var keyboardHeight: CGFloat = 0.0
    var bottomInset: CGFloat {
        return bottomSafeAreaInset > 0.0 ? 0.0 : 14.0
    }
    var scrolled: Bool = false
    
    var performer: OrderPerformer!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if performer.performer?.phoneNumber == nil {
            navigationItem.rightBarButtonItem = nil
        }
        view.backgroundColor = UIColor.default_bgColor
        bindScrollViewToKeyboard(tableView)
        title = performer.performer?.fullName.name
        presentationModel.updateHandler = { [weak self] in
            self?.datasource.update(messages: $0)
        }
        presentationModel.messageSended = { [weak self] in
            self?.resetText()
        }
        presentationModel.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !scrolled else { return }
        scrolled = true
        scrollToBottom()
    }
    
    override func showHUD() {
        chatButton.isHidden = true
        chatIndicator.isHidden = false
        chatIndicator.startAnimating()
    }
    
    override func hideHUD() {
        chatButton.isHidden = false
        chatIndicator.isHidden = true
        chatIndicator.stopAnimating()
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callAction() {
        guard let phone = performer.performer?.phoneNumber else { return }
        guard let url = URL(string: "tel://+"+phone) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func chatBtnTapped() {
        sendMessage(text: chatTextView.text)
    }
    
    
    func sendMessage(text: String) {
        if !text.isEmpty {
            guard let performerId = performer.performer?.id else { return }
            presentationModel.sendMessage(message: text, performerId: performerId)
        }
    }
    
}

extension OrderChatViewController: UITextViewDelegate {
    func resetText() {
        chatTextView.text = ""
        chatButton.isEnabled = false
        scrollToBottom()
    }
    
    func checkPlaceholder() {
        if chatTextView.text.trim().isEmpty {
            chatTextView.text = placeholder
            chatTextView.textColor = placeholderColor
        } else {
            chatTextView.textColor = .black
        }
        chatButton.isEnabled = !chatTextView.text.trim().isEmpty && chatTextView.text.trim() != placeholder
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard !presentationModel.isLoading else { return false }
        if text == "\n" {
            let text = textView.text.trim()
            sendMessage(text: text)
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight + ceil(textView.frame.height) + 30.0 + bottomInset, right: 0.0)
        chatButton.isEnabled = !textView.text.trim().isEmpty && textView.text.trim() != placeholder
        scrollToBottom()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkPlaceholder()
    }
    
    func scrollToBottom() {
        if datasource.messages.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: datasource.messages.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let targetInset =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height + ceil(chatTextView.frame.height) + 30.0 + bottomInset, right: 0.0)
            keyboardHeight = keyboardSize.height
            chatInputViewBottom.constant = keyboardSize.height + bottomInset
            tableView.contentInset = targetInset
            delay(0.3) { [weak self] in
                self?.scrollToBottom()
            }
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0.0
        let targetInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: ceil(chatTextView.frame.height) + 50.0 + bottomInset, right: 0.0)
        chatInputViewBottom.constant = 14.0
        tableView.contentInset = targetInset
        view.layoutIfNeeded()
    }
}
