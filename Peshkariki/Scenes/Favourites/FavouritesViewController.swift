//
//  FavouritesViewController.swift
//  Peshkariki
//
//  Created by sergey on 30.04.2022.
//

import UIKit

class FavouritesViewController: UITableViewController, DataChangedDelegate {
    
    // MARK: DataChangedDelegate
    func alert(title: String, message: String) {}
    
    func viewModelUpdate() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favouritesViewModel.favouritesDelegate = self
    }
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouritesViewModel.favouriteList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "picture", for: indexPath) as! PictureTableViewCell
        cell.label.text = favouritesViewModel.favouriteList[indexPath.row].user.name!
        cell.picture.image = favouritesViewModel.favouriteListImages[indexPath.row]
        
        return cell
    }
    
    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return homeViewModel.cellSize!.width
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pictureDetailsVC = segue.destination as! PictureDetailsViewController
        let cell = sender as! PictureTableViewCell
        let index = tableView.indexPath(for: cell)!.row
        
        pictureDetailsVC.image = cell.picture.image
        pictureDetailsViewModel.stats = favouritesViewModel.favouriteList[index]
    }
    
    // MARK: - IBAction
    @IBAction func favButtonPressed(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? PictureTableViewCell else {
            return
        }
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        favouritesViewModel.favouriteListImages.remove(at: index)
        favouritesViewModel.favouriteList.remove(at: index)
    }
}
