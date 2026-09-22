//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Adilkhan on 21/9/26.
//

import Foundation

final class OAuth2TokenStorage{
    private let storage: UserDefaults = .standard
    
    var accessToken: String? {
        get { storage.string(forKey: "access_token") }
        set { storage.set(newValue, forKey: "access_token") }
    }
}
