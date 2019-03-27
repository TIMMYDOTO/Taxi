//
//  ChatFromViewCell.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/10/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import SDWebImage
protocol ChatFromViewCellProtocol {
    func didTapAttachment(attachment: UIImageView)
}
class ChatFromViewCell: UITableViewCell {

    
    var attachementImgView = UIImageView()
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var paperClipButton: UIButton!
    
    @IBOutlet var messageTextView: UITextView!
    var delegate: ChatFromViewCellProtocol?
    func fillWithAnswer(answer: Answer) -> ChatFromViewCell{
       
        nameLabel.text = answer.user_info.name
        messageTextView.text = answer.answer
        if answer.path_file.isEmpty {
            paperClipButton.isHidden = true
            attachementImgView.image = nil
     
        }else{
            paperClipButton.isHidden = false
            attachementImgView.sd_setImage(with: URL(string:answer.path_file + "/client?"  + AvtoletService.shared.getToken()), placeholderImage: UIImage())
        }
        return self
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func attachmentTapped(_ sender: UIButton) {
        delegate?.didTapAttachment(attachment: attachementImgView)
    }
}
