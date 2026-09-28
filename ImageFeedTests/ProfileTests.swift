//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Adilkhan on 28/9/26.
//

import XCTest
@testable import ImageFeed

@MainActor
final class ProfileTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterUpdatesProfileDetails() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub()
        profileService.profileViewModel = ProfileViewModel(
            username: "axretit",
            name: "Adilkhan Niiazov",
            login: "@axretit",
            bio: "Hello"
        )
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileImageService: ProfileImageServiceStub(),
            profileLogoutService: ProfileLogoutServiceSpy()
        )
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
        XCTAssertEqual(viewController.name, "Adilkhan Niiazov")
        XCTAssertEqual(viewController.login, "@axretit")
        XCTAssertEqual(viewController.bio, "Hello")
    }

    func testPresenterDoesNotUpdateProfileDetailsWithoutProfile() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(
            profileService: ProfileServiceStub(),
            profileImageService: ProfileImageServiceStub(),
            profileLogoutService: ProfileLogoutServiceSpy()
        )
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertFalse(viewController.updateProfileDetailsCalled)
    }

    func testPresenterUpdatesAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileImageService = ProfileImageServiceStub()
        profileImageService.avatarURL = "https://images.unsplash.com/avatar.jpg"
        let presenter = ProfileViewPresenter(
            profileService: ProfileServiceStub(),
            profileImageService: profileImageService,
            profileLogoutService: ProfileLogoutServiceSpy()
        )
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.avatarURL, URL(string: "https://images.unsplash.com/avatar.jpg"))
    }

    func testPresenterUpdatesAvatarOnNotification() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileImageService = ProfileImageServiceStub()
        let presenter = ProfileViewPresenter(
            profileService: ProfileServiceStub(),
            profileImageService: profileImageService,
            profileLogoutService: ProfileLogoutServiceSpy()
        )
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.viewDidLoad()

        //when
        profileImageService.avatarURL = "https://images.unsplash.com/new_avatar.jpg"
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)

        //then
        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.avatarURL, URL(string: "https://images.unsplash.com/new_avatar.jpg"))
    }

    func testPresenterDoesNotUpdateAvatarWithoutURL() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter(
            profileService: ProfileServiceStub(),
            profileImageService: ProfileImageServiceStub(),
            profileLogoutService: ProfileLogoutServiceSpy()
        )
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertFalse(viewController.updateAvatarCalled)
    }

    func testPresenterLogout() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profileLogoutService = ProfileLogoutServiceSpy()
        let presenter = ProfileViewPresenter(
            profileService: ProfileServiceStub(),
            profileImageService: ProfileImageServiceStub(),
            profileLogoutService: profileLogoutService
        )
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        presenter.didConfirmLogout()

        //then
        XCTAssertTrue(profileLogoutService.logoutCalled)
        XCTAssertTrue(viewController.switchToSplashScreenCalled)
    }
}
