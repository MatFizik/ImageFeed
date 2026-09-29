//
//  ProfileServiceStubs.swift
//  ImageFeedTests
//
//  Created by Adilkhan on 28/9/26.
//

@testable import ImageFeed
import Foundation

@MainActor
final class ProfileServiceStub: ProfileServiceProtocol {
    var profileViewModel: ProfileViewModel?
}

@MainActor
final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String?
}

@MainActor
final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    var logoutCalled: Bool = false

    func logout() {
        logoutCalled = true
    }
}
