//
//  CocktailTableViewCell.swift
//  AlamofireExample
//
//  Created by cano on 2023/05/12.
//

import UIKit
import AlamofireImage

class CocktailTableViewCell: UITableViewCell {

    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var drinkDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.clear()
    }
    
    func clear() {
        self.drinkImageView.image = UIImage()
        self.drinkNameLabel.text = ""
        self.drinkDescriptionLabel.text = ""
    }
    
    func configure(_ item: Cocktail) {
        self.clear()
        
        if let imageURL = item.strDrinkThumb {
            let url = URL(string: imageURL)!
            self.drinkImageView.af.setImage(withURL: url, placeholderImage: UIImage(named: "loading"), imageTransition: .crossDissolve(1))
        }
        self.drinkNameLabel.text = item.strDrink
        self.drinkDescriptionLabel.text = item.strInstructions
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
