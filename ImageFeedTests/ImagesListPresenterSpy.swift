//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Adilkhan on 28/9/26.
//

@testable import ImageFeed
import Foundation

@MainActor
final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var viewDidLoadCalled: Bool = false

    var view: ImagesListViewControllerProtocol?

    var photosCount: Int = 0

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func photo(at index: Int) -> PhotoViewModel {
        PhotoViewModel(
            id: "\(index)",
            size: CGSize(width: 1, height: 1),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        )
    }

    func cellHeight(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        0
    }

    func willDisplayCell(at index: Int) {

    }

    func didTapLike(at index: Int) {

    }
}
