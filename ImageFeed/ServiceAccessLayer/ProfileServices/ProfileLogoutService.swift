//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Adilkhan on 25/9/26.
//

import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() {}
    
    let profileService = ProfileService.shared
    let profileImageService = ProfileImageService.shared
    let imageListService = ImageListService.shared
    
    func logout() {
        KeychainWrapper.standard.remove(forKey: KeychainWrapper.Key(rawValue: Constants.keyAccessToken))
        profileService.clearProfileData()
        profileImageService.clearAvatarUrl()
        imageListService.clearPhotosData()
        cleanCookies()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
