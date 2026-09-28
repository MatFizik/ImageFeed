//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Adilkhan on 28/9/26.
//

import ImageFeed
import Foundation

@MainActor
final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?

    var updateProfileDetailsCalled: Bool = false
    var name: String?
    var login: String?
    var bio: String?

    var updateAvatarCalled: Bool = false
    var avatarURL: URL?

    var switchToSplashScreenCalled: Bool = false

    func updateProfileDetails(name: String, login: String, bio: String?) {
        updateProfileDetailsCalled = true
        self.name = name
        self.login = login
        self.bio = bio
    }

    func updateAvatar(url: URL) {
        updateAvatarCalled = true
        avatarURL = url
    }

    func switchToSplashScreen() {
        switchToSplashScreenCalled = true
    }
}
