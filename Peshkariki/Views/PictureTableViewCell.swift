//
//  PictureTableViewCell.swift
//  Peshkariki
//
//  Created by sergey on 05.05.2022.
//

import UIKit

class PictureTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let size = homeViewModel.cellSize {
            let constraintW = NSLayoutConstraint(item: picture!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: size.width)
            picture.addConstraint(constraintW)
        }
    }
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var picture: UIImageView!
    
}
