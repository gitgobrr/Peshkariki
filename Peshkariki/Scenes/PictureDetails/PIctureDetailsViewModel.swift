//
//  PIctureDetailsViewModel.swift
//  Peshkariki
//
//  Created by sergey on 18.06.2022.
//

import Foundation
import UIKit.UIImage


class PictureDetailsViewModel {
    var pictureDelegate: DataChangedDelegate?
    
    var stats: Picture? {
        didSet {
            pictureDelegate?.viewModelUpdate()
        }
    }
    
    var task: URLSessionDataTask?
    
    func getPictureStats(id: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Unsplash.scheme
        urlComponents.host = Unsplash.host
        urlComponents.path = Unsplash.photoPath+id
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Unsplash.clientID)
        ]
        
        let url = urlComponents.url!
        task = URLSession.shared.dataTask(with: url) { apiData, apiResp, apiErr in
            guard apiErr == nil else {
                print("Request error: ",apiErr!)
                return
            }
            guard let response = apiData else {
                print("No data")
                return
            }
            
            do {
                self.stats = try JSONDecoder().decode(Picture.self, from: response)
            } catch let jsonErr {
                print(jsonErr)
                let responseStr = String(data: response, encoding: .utf8)!
                print(responseStr)
                if responseStr.hasPrefix("Rate") {
                    self.pictureDelegate?.alert(title: responseStr, message: "Please come back later")
                }
            }
        }
        task?.resume()
    }
}

let pictureDetailsViewModel = PictureDetailsViewModel()
