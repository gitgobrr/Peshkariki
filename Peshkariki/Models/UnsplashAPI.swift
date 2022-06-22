//
//  UnsplashAPI.swift
//  Peshkariki
//
//  Created by sergey on 30.04.2022.
//

import Foundation


struct Response: Decodable {
    let total: Int
    let total_pages: Int
    let results: [Picture]
}

struct Picture: Decodable {
    let id: String
    let user: User
    let created_at: String
    let blur_hash: String?
    let urls: [String: URL]
    let location: Location?
    let downloads: UInt32?
}

struct Location: Decodable {
    let name: String?
}
struct User: Decodable {
    let name: String?
}

enum Unsplash {
    static let scheme = "https"
    static let host = "api.unsplash.com"
    static let randomPath = "/photos/random"
    static let searchPath = "/search/photos"
    static let photoPath = "/photos/"
    static let clientID = Secrets.clientID
}

extension Unsplash {
    enum Secrets {
        static let clientID = Secrets.environmentVariable(named: "UNSPLASH_CLIENT_ID") ?? ""
        
        private static func environmentVariable(named: String) -> String? {
            guard let infoDictionary = Bundle.main.infoDictionary, let value = infoDictionary[named] as? String else {
                print("Missing Environment Variable: '\(named)'")
                return nil
            }
            return value
        }
    }
}

