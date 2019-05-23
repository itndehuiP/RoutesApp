//
//  SavedRouteCollectionViewCell.swift
//  RoutesApp
//
//  Created by ItandehuiP on 5/10/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import UIKit

class SavedRouteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectionImage: UIImageView!
    
     ///Customize the cell, when this is loaded
    override func awakeFromNib() {
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 2.0
    }
    
    ///Defines the state of the selection Image of the cell
    var isEditing: Bool = false {
        didSet {
            selectionImage.isHidden = !isEditing
        }
    }
    
    ///Defines the behavior of the cell according to it's selected state.
    override var isSelected: Bool {
        didSet {
            if self.isEditing {
                selectionImage.image = isSelected ? UIImage(named: "selectedButton") : UIImage(named: "unSelectedButton")
            }
            
            if self.isSelected && !isEditing {
                let colorPalette = ColorPalette()
                self.backgroundColor = colorPalette.primaryLightColor
            }
            else {
                self.backgroundColor = .white
            }
        }
    }
    
}
