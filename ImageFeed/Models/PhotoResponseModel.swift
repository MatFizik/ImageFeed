//
//  PhotoResponseModel.swift
//  ImageFeed
//
//  Created by Adilkhan on 23/9/26.
//

import Foundation

struct PhotoResponseModel: Codable {
    let id: String
    let width: Int
    let height: Int
    let welcomeDescription: String?
    let createdAt: Date?
    let urls: PhotoUrl
    
    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case welcomeDescription = "description"
        case createdAt = "created_at"
        case urls
    }
}

struct PhotoUrl: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
//[
//  {
//    "created_at": "2016-05-03T11:00:28-04:00",
//    "updated_at": "2016-07-10T11:00:01-05:00",
//    "width": 5245,
//    "height": 3497,
//    "color": "#60544D",
//    "blur_hash": "LoC%a7IoIVxZ_NM|M{s:%hRjWAo0",
//    "description": "A man drinking a coffee.",
//    "urls": {
//      "raw": "https://images.unsplash.com/face-springmorning.jpg",
//      "full": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg",
//      "regular": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=1080&fit=max",
//      "small": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=400&fit=max",
//      "thumb": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=200&fit=max"
//    },
//  },
//  // ... more photos
//]
