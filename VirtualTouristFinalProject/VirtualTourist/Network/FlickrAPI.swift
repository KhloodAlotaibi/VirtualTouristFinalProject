//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Khlood on 7/30/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import Foundation 

class FlickrAPI {
    
    class func searchPhotos(_ lon: Double, _ lat: Double, _ page: Int, completion: @escaping (Photos?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=5461cbc26b3b987c7f484babfea4c5e3&lat=\(lat)&lon=\(lon)&page=\(page)&per_page=10&extras=url_m&accuracy=11&format=json&nojsoncallback=1")!)   
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(nil, error)
                return
            }
            if statusCode >= 200 && statusCode < 300 {
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(SearchPhotosResponse.self, from: data!)
                    completion(response.photos, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    class func downloadImage(_ url: URL, completion: @escaping (_ imageData: Data?, Error?) -> Void){
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
}
