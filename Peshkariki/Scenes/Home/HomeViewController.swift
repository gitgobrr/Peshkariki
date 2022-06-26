//
//  HomeViewController.swift
//  Peshkariki
//
//  Created by sergey on 30.04.2022.
//

import UIKit

private let reuseIdentifier = "picture"

extension UICollectionView {

    var itemsPerRow: CGFloat { 2 }
    var flowLayout: UICollectionViewFlowLayout! {
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = .init(top: 10, left: 10, bottom: 0, right: 10)
        
        return layout
    }
}

class HomeViewController: UICollectionViewController {
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        homeViewModel.homeDelegate = self
        homeViewModel.fetchData()
    }
    
    var searchText: String? = nil
    let viewModel = HomeViewModel()
    
    func configureCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        let sectionInsetWidth = collectionView.flowLayout.sectionInset.left * collectionView.itemsPerRow
        let interItemWidth = (collectionView.itemsPerRow - 1) * collectionView.flowLayout.minimumInteritemSpacing
        let paddingWidth = sectionInsetWidth + interItemWidth
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / collectionView.itemsPerRow
        
        homeViewModel.cellSize = CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pictureDetailsVC = segue.destination as! PictureDetailsViewController
        let cell = sender as! PictureCell
        pictureDetailsVC.image =  cell.picture.image
    
        if searchText == nil {
            pictureDetailsViewModel.stats = cell.stats
        } else {
            pictureDetailsViewModel.getPictureStats(id: cell.stats!.id)
        }
    }

    // MARK:  UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeViewModel.images.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PictureCell
        
        cell.picture.image = homeViewModel.images[indexPath.item]
        cell.stats = homeViewModel.pictureList[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let searchView = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "searchBar", for: indexPath)
        
        return searchView
    }
    
    // MARK:  UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == homeViewModel.pictureList.count-1 {
            if let query = searchText {
                homeViewModel.currentPage += 1
                homeViewModel.realPage = homeViewModel.currentPage
                homeViewModel.searchData(query: query, page: homeViewModel.currentPage)
            } else {
                homeViewModel.fetchData()
            }
        }
    }
}


// MARK: - Search Bar
extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        for task in homeViewModel.searchTasks {
            task.cancel()
        }
        homeViewModel.searchTasks.removeAll()
        if (searchBar.text!.isEmpty) {
            homeViewModel.pictureList = homeViewModel.realList
            homeViewModel.images = homeViewModel.realImages
            homeViewModel.currentPage = homeViewModel.realPage
            searchText = nil
        } else {
            homeViewModel.pictureList.removeAll()
            homeViewModel.images.removeAll()
            homeViewModel.currentPage = 1
            
            searchText = searchBar.text!.lowercased()
            homeViewModel.searchData(query: searchText!, page: homeViewModel.currentPage)
        }
    }
}

// MARK: - DataChangedDelegate
extension HomeViewController: DataChangedDelegate {
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func viewModelUpdate() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return homeViewModel.cellSize!
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.flowLayout.minimumLineSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.flowLayout.minimumInteritemSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionView.flowLayout.sectionInset
    }
}

