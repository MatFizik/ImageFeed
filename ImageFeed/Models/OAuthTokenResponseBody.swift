//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Adilkhan on 20/9/26.
//

struct OAuthTokenResponseBody: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}
