//
//  PictureDetailsViewController.swift
//  Peshkariki
//
//  Created by sergey on 02.05.2022.
//

import UIKit

class PictureDetailsViewController: UIViewController, DataChangedDelegate, PictureChangedDelegate {
    
    
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateImage(difference: (old: UIImage, new: UIImage)) {
        if self.image!.isEqual(difference.old) {
            DispatchQueue.main.async {
                self.image = difference.new
                self.detailPicture.image = self.image
            }
        }
    }

    func viewModelUpdate() {
        DispatchQueue.main.async {
            self.configurePicture()
        }
    }
    
    //MARK: -
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pictureDetailsViewModel.pictureDelegate = self
        homeViewModel.pictureDelegate = self
        configurePicture()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        pictureDetailsViewModel.pictureDelegate = nil
        pictureDetailsViewModel.task?.cancel()
        pictureDetailsViewModel.task = nil
        pictureDetailsViewModel.stats = nil
    }
    
    func configurePicture() {
        detailPicture.image = image
        guard pictureDetailsViewModel.stats != nil else {
            return
        }
        headerStats.author.text = pictureDetailsViewModel.stats!.user.name
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        if let date = format.date(from: pictureDetailsViewModel.stats!.created_at) {
            headerStats.date.text = date.formatted(date: .abbreviated, time: .omitted)
        }
        
        if let location = pictureDetailsViewModel.stats!.location?.name {
            let label = footerStats.locationStack.subviews[1] as! UILabel
            label.text = location
        } else {
            footerStats.locationStack.isHidden = true
        }
        if let downloadsCount = pictureDetailsViewModel.stats!.downloads {
            let label = footerStats.downloadsStack.subviews[1] as! UILabel
            label.text = String(downloadsCount)
        } else {
            footerStats.downloadsStack.isHidden = true
        }
        
        if favouritesViewModel.favouriteList.contains(where: { pic in
            pic.id == pictureDetailsViewModel.stats!.id
        }) {
            star.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            star.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        
        headerStats.isHidden = false
        footerStats.isHidden = false
    }
    
    // MARK: @IBOutlet
    
    @IBOutlet weak var detailPicture: PictureView!
    @IBOutlet weak var headerStats: StatsView!
    @IBOutlet weak var footerStats: StatsView!
    
    @IBOutlet weak var star: UIButton!
    
    // MARK: @IBAction
    
    @IBAction func favButtonPressed(_ sender: UIButton) {
        if let index = favouritesViewModel.favouriteList.firstIndex(where: { pic in
            pic.id == pictureDetailsViewModel.stats!.id
        }) {
            favouritesViewModel.favouriteList.remove(at: index)
            favouritesViewModel.favouriteListImages.remove(at: index)
            sender.setImage(UIImage(systemName: "star"), for: .normal)
        } else {
            favouritesViewModel.favouriteList.append(pictureDetailsViewModel.stats!)
            favouritesViewModel.favouriteListImages.append(image!)
            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
    }
    
}
