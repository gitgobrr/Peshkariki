//
//  File.swift
//  Peshkariki
//
//  Created by sergey on 05.05.2022.
//

import Foundation
import UIKit.UIImage

protocol PictureChangedDelegate {
    func updateImage(difference: (old: UIImage, new: UIImage))
}

protocol DataChangedDelegate {
    func viewModelUpdate()
    func alert(title: String, message: String)
}

class HomeViewModel {
    
    var homeDelegate: DataChangedDelegate?
    var pictureDelegate: PictureChangedDelegate?

    var pictureList: [Picture]
    var images: [UIImage] { // image List
        didSet {
            homeDelegate?.viewModelUpdate()
            if let difference = zip(oldValue, images).first(where: { (old,new) in
                !(old.isEqual(new))
            }) {
                pictureDelegate?.updateImage(difference: difference)
                if let index = favouritesViewModel.favouriteListImages.firstIndex(where: { img in
                    img.isEqual(difference.0)
                }) {
                    favouritesViewModel.favouriteListImages[index] = difference.1
                }
            }
        }
    }
    
    var realList: [Picture]
    var realImages: [UIImage]
    
    var currentPage: UInt8 = 1
    var realPage: UInt8 = 1
    
    var cellSize: CGSize?
    // MARK: - Loading images from the web
    
    var fetchTasks: [URLSessionDataTask] = []
    var searchTasks: [URLSessionDataTask] = []
    let imgSize = "regular"
    
    func fetchData() {
        var urlComponents = URLComponents()
        urlComponents.scheme = Unsplash.scheme
        urlComponents.host = Unsplash.host
        urlComponents.path = Unsplash.randomPath
        urlComponents.queryItems = [
            URLQueryItem(name: "count", value: "30"),
            URLQueryItem(name: "client_id", value: Unsplash.clientID)
        ]
        let url = urlComponents.url!
        URLSession.shared.dataTask(with: url) { apiData, apiResp, apiErr in
            guard apiErr == nil else {
                print("Request error: ",apiErr!)
                return
            }
            guard let response = apiData else {
                print("No data")
                return
            }
            
            var newPictures: [Picture] = []
            
            do {
                newPictures = try JSONDecoder().decode([Picture].self, from: response)
                self.pictureList.append(contentsOf: newPictures)
                self.realList = self.pictureList
            } catch let jsonErr {
                print(jsonErr)
                let responseStr = String(data: response, encoding: .utf8)!
                print(responseStr)
                if responseStr.hasPrefix("Rate") {
                    self.homeDelegate?.alert(title: responseStr, message: "Please come back later")
                }
            }

            newPictures.forEach { picture in
                self.images.append(UIImage(blurHash: picture.blur_hash ?? "000000",
                                           size: CGSize(width: 32, height: 32))!)
                self.realImages.append(self.images.last!)
                let task = URLSession.shared.dataTask(with: picture.urls[self.imgSize]!) { imgData, imgResponse, imgErr in
                    guard imgErr == nil else {
                        print("Request error for image: ",imgErr!)
                        return
                    }
                    guard let img = imgData else {
                        print("No data")
                        return
                    }
                    
                    if let index = (self.fetchTasks.firstIndex { task in
                        task.originalRequest?.url == picture.urls[self.imgSize]
                    }) {
                        self.images[index] = (UIImage(data: img)!)
                        self.realImages[index] = self.images[index]
                    }
                }
                task.resume()
                self.fetchTasks.append(task)
            }
        }.resume()
    }
    
    func searchData(query: String, page: UInt8) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Unsplash.scheme
        urlComponents.host = Unsplash.host
        urlComponents.path = Unsplash.searchPath
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "client_id", value: Unsplash.clientID)
        ]
        let url = urlComponents.url!
        URLSession.shared.dataTask(with: url) { apiData, apiResp, apiErr in
            guard apiErr == nil else {
                print("Request error: ",apiErr!)
                return
            }
            guard let response = apiData else {
                print("No data")
                return
            }
            
            var newPictures: Response?
            
            do {
                newPictures = try JSONDecoder().decode(Response.self, from: response)
                self.pictureList.append(contentsOf: newPictures!.results)
            } catch let jsonErr {
                print(jsonErr)
                let responseStr = String(data: response, encoding: .utf8)!
                print(responseStr)
                if responseStr.hasPrefix("Rate") {
                    self.homeDelegate?.alert(title: responseStr, message: "Please come back later")
                }
            }
            
            newPictures?.results.forEach { picture in
                self.images.append(UIImage(blurHash: picture.blur_hash ?? "000000",
                                           size: CGSize(width: 32, height: 32))!)
                let task = URLSession.shared.dataTask(with: picture.urls[self.imgSize]!) { imgData, imgResponse, imgErr in
                    guard imgErr == nil else {
                        print("Request error for image: ",imgErr!)
                        return
                    }
                    guard let img = imgData else {
                        print("No data")
                        return
                    }
                    
                    if let index = (self.searchTasks.firstIndex { task in
                        task.originalRequest?.url == picture.urls[self.imgSize]
                    }) {
                        self.images[index] = (UIImage(data: img)!)
                    }
                }
                task.resume()
                self.searchTasks.append(task)
            }
        }.resume()
    }

    // MARK: - Initialization
    
    init() {
        self.pictureList = []
        self.images = []
        self.realList = []
        self.realImages = []
    }
    
    init(picList: [Picture], imgs: [UIImage], reals: [Picture], realImgs: [UIImage]) {
        self.pictureList = picList
        self.images = imgs
        self.realList = reals
        self.realImages = realImgs
    }
}

let homeViewModel = HomeViewModel()
