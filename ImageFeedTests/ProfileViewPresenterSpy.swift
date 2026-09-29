//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Adilkhan on 28/9/26.
//

import ImageFeed
import Foundation

@MainActor
final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var didConfirmLogoutCalled: Bool = false

    var view: ProfileViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didConfirmLogout() {
        didConfirmLogoutCalled = true
    }
}
