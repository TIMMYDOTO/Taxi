//
//  ChatChatRouter.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 03/04/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

struct ChatRouter: Router {

    let storyboard: UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
    weak var presenter: UIViewController?


    func presentChat(performer: OrderPerformer) {
        let vc = storyboard.instantiateInitialViewController() as! CommonNavigationController
        if let chatVC = vc.topViewController as? OrderChatViewController {
            chatVC.performer = performer
        }
        presentModal(vc)
    }
    func showSupportHistory() {
        let vc = storyboard.instantiateViewController(withClass: SupportHistoryVC.self)
        show(vc)
    }
    
    func showSupportChat(identifier: Int) {
        let vc = storyboard.instantiateViewController(withClass: SupportChatVC.self)
        vc.identifier = String(identifier)
        show(vc)
    }
    
    
}
