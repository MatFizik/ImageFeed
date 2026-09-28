//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Adilkhan on 28/9/26.
//

@testable import ImageFeed
import Foundation

@MainActor
final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?

    var updateTableViewAnimatedCalled: Bool = false

    var setIsLikedCalled: Bool = false
    var isLiked: Bool?
    var likedIndex: Int?

    var showLoadingIndicatorCalled: Bool = false
    var hideLoadingIndicatorCalled: Bool = false
    var showLikeErrorAlertCalled: Bool = false

    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }

    func setIsLiked(_ isLiked: Bool, at index: Int) {
        setIsLikedCalled = true
        self.isLiked = isLiked
        likedIndex = index
    }

    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }

    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }

    func showLikeErrorAlert() {
        showLikeErrorAlertCalled = true
    }
}
