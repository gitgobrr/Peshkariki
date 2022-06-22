//
//  FavouritesViewModel.swift
//  Peshkariki
//
//  Created by sergey on 19.06.2022.
//

import Foundation
import UIKit.UIImage

class FavoritesViewModel {
    var favouritesDelegate: DataChangedDelegate?
    
    var favouriteList: [Picture]
    var favouriteListImages: [UIImage] {
        didSet {
            favouritesDelegate?.viewModelUpdate()
        }
    }
    
    init() {
        self.favouriteList = []
        self.favouriteListImages = []
    }
    
    init(favs: [Picture],favImgs: [UIImage])
    {
        self.favouriteList = favs
        self.favouriteListImages = favImgs
    }
}

let favouritesViewModel = FavoritesViewModel()

