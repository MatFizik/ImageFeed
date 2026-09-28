//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Adilkhan on 28/9/26.
//

import Foundation

public protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didConfirmLogout()
}

protocol ProfileServiceProtocol {
    var profileViewModel: ProfileViewModel? { get }
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}

protocol ProfileLogoutServiceProtocol {
    func logout()
}

extension ProfileService: ProfileServiceProtocol {}
extension ProfileImageService: ProfileImageServiceProtocol {}
extension ProfileLogoutService: ProfileLogoutServiceProtocol {}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol

    private var profileImageServiceObserver: NSObjectProtocol?

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        profileLogoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }

    nonisolated deinit {}

    func viewDidLoad() {
        updateProfileDetails()

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }

    func didConfirmLogout() {
        profileLogoutService.logout()
        view?.switchToSplashScreen()
    }

    private func updateProfileDetails() {
        guard let profile = profileService.profileViewModel else { return }
        view?.updateProfileDetails(name: profile.name, login: profile.login, bio: profile.bio)
    }

    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(url: imageUrl)
    }
}
