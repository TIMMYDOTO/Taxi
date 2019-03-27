//
//  SupportHistoryCell.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/25/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class SupportHistoryCell: UITableViewCell {

    
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var topic: UILabel!
    
    @IBOutlet var time: UILabel!
    
    var identifier : Int!
    var dateFormatter = DateFormatter()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func fillWithReport(report: Report) -> SupportHistoryCell{
        if report.checked == 1{
        self.statusLabel.textColor = UIColor(red: 254/255, green: 146/255, blue: 1/255, alpha: 1)
        self.statusLabel.text = "Обращение закрыто"
            
        self.topic.textColor = UIColor(red: 172/255, green: 172/255, blue: 172/255, alpha: 1)
            
        }
        if report.checked == 0 {
            self.statusLabel.textColor = UIColor(red: 136/255, green: 201/255, blue: 24/255, alpha: 1)
            self.statusLabel.text = "Обращение открыто"
            
            self.topic.textColor = .black
        }
        
        self.topic.text = report.topic
        
        let date = Date(timeIntervalSince1970: Double(report.timestamp) ?? 0.0)
        dateFormatter.dateFormat = "dd.MM.yyyy год"
        self.time.text = dateFormatter.string(from: date)
       
        self.identifier = report.report_id
        return self
    }
}
