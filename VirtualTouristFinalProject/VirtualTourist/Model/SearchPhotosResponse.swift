//
//  SearchPhotosResponse.swift
//  VirtualTourist
//
//  Created by Khlood on 7/30/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import Foundation 
  
struct SearchPhotosResponse: Codable {
    var photos: Photos 
    var stat: String
}

struct Photos: Codable {
    var page, pages, perPage: Int
    var total: String
    var photo: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page, pages, total, photo
        case perPage = "perpage"
    }
}

struct Photo: Codable {
    var id, owner, secret, server, title, url : String
    var farm, isPublic, isFriend, isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        case url = "url_m"
    }
}
