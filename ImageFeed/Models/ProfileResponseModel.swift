//
//  ProfileResponse.swift
//  ImageFeed
//
//  Created by Adilkhan on 21/9/26.
//

struct ProfileResponseModel: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
