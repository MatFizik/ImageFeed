//
//  PhotoModel.swift
//  ImageFeed
//
//  Created by Adilkhan on 23/9/26.
//

import Foundation

struct PhotoViewModel {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
