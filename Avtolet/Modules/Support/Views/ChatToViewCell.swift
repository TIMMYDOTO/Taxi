//
//  ChatToViewCell.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/10/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
protocol ChatToViewCellProtocol {
    func didTapAttachment(attachement: UIImageView)
}
class ChatToViewCell: UITableViewCell {

     var attachmentImgView = UIImageView()
    
    @IBOutlet var paperClipButton: UIButton!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var messageTextView: UITextView!
    
    var delegate:ChatToViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func fillWithAnswer(answer: Answer) -> ChatToViewCell{
        
        nameLabel.text = answer.user_info.full_name
 
        messageTextView.text = answer.answer
        if answer.path_file.isEmpty {
            paperClipButton.isHidden = true
            attachmentImgView.image = nil
                
        }else{
            paperClipButton.isHidden = false

            attachmentImgView.sd_setImage(with: URL(string:answer.path_file + "/client?"  + AvtoletService.shared.getToken()), placeholderImage: UIImage())

        }
        return self
    }
    @IBAction func attachmentTapped(_ sender: UIButton) {
        delegate?.didTapAttachment(attachement: attachmentImgView)
    }
    
}
