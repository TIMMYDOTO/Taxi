//
//  FavoritePerformerCell.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/25/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
protocol FavoritePerformerCellDelegate {
    func didTapReMoveFavorite(performer_id: Int)
}
class FavoritePerformerCell: UITableViewCell {
    
    var delegate: FavoritePerformerCellDelegate?
    
    @IBOutlet var performerImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var carTypeLabel: UILabel!
    
    @IBOutlet var carNumberLabel: UILabel!
    
    @IBOutlet var colorLabel: UILabel!
    
    @IBOutlet var starLabel: UILabel!
    
    @IBOutlet var removeFavoritePerformer: UIButton!
    var favoriteId: Int!
    
    func fillWithDataSource(favorite: Favorite_performers) -> UITableViewCell{
       
        performerImageView.image = UIImage(imageLiteralResourceName: "clerk")
        var dict = convertToDictionary(text: favorite.full_name)
        let name = dict!["name"] as! String
        let surname = dict!["surname"] as! String
        nameLabel.text = name + " " + surname
        carTypeLabel.text = favorite.mark + " " + favorite.model + " - "
        carTypeLabel.sizeToFit()
        carNumberLabel.text = favorite.state_number
        carNumberLabel.sizeToFit()
        colorLabel.text =  String(format: "(%@)", favorite.color_car)
        colorLabel.sizeToFit()
        starLabel.text = favorite.rating.first
        favoriteId = favorite.performer_id
        return self
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @IBAction func didTapRemoveFavorite(_ sender: UIButton) {
        delegate?.didTapReMoveFavorite(performer_id: favoriteId)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
