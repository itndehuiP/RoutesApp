//
//  RouteCollectionViewCell.swift
//  RoutesApp
//
//  Created by ItandehuiP on 4/29/19.
//  Copyright © 2019 ItandehuiP. All rights reserved.
//

import UIKit

class RouteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var indexLabel : UILabel!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var selectionImage: UIImageView!
    
    ///Customizes the cell, when this is loaded
    override func awakeFromNib() {
       let colorPalette = ColorPalette()
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 2.0
        self.layer.borderColor =  colorPalette.secondaryDarkColor.cgColor
        titleLabel.numberOfLines = 2
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
                self.backgroundColor = colorPalette.secondaryLightColor
                }
                else {
                self.backgroundColor = .white
            }
        }
    }
    
    
    
    
    
    
}
