//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Adilkhan on 28/9/26.
//

import XCTest
@testable import ImageFeed

@MainActor
final class ImagesListTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        _ = viewController.view

        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterFetchesPhotosOnViewDidLoad() {
        //given
        let imageListService = ImageListServiceStub()
        let presenter = ImagesListPresenter(imageListService: imageListService)

        //when
        presenter.viewDidLoad()

        //then
        XCTAssertEqual(imageListService.fetchPhotosNextPageCallsCount, 1)
    }

    func testPresenterUpdatesTableWhenPhotosChanged() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let imageListService = ImageListServiceStub()
        let presenter = ImagesListPresenter(imageListService: imageListService)
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.viewDidLoad()

        //when
        imageListService.photos = [makePhoto(id: "1"), makePhoto(id: "2")]
        NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)

        //then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
        XCTAssertEqual(presenter.photosCount, 2)
        XCTAssertEqual(presenter.photo(at: 1).id, "2")
    }

    func testPresenterFetchesNextPageWhenLastCellWillDisplay() {
        //given
        let imageListService = ImageListServiceStub()
        let presenter = makePresenterWithPhotos(count: 3, imageListService: imageListService)
        let callsCountBefore = imageListService.fetchPhotosNextPageCallsCount

        //when
        presenter.willDisplayCell(at: 2)

        //then
        XCTAssertEqual(imageListService.fetchPhotosNextPageCallsCount, callsCountBefore + 1)
    }

    func testPresenterDoesNotFetchNextPageWhenNotLastCellWillDisplay() {
        //given
        let imageListService = ImageListServiceStub()
        let presenter = makePresenterWithPhotos(count: 3, imageListService: imageListService)
        let callsCountBefore = imageListService.fetchPhotosNextPageCallsCount

        //when
        presenter.willDisplayCell(at: 0)

        //then
        XCTAssertEqual(imageListService.fetchPhotosNextPageCallsCount, callsCountBefore)
    }

    func testCellHeight() {
        //given
        let imageListService = ImageListServiceStub()
        let presenter = makePresenterWithPhotos(count: 0, imageListService: imageListService)
        imageListService.photos = [makePhoto(id: "1", size: CGSize(width: 200, height: 100))]
        NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)

        //when
        let height = presenter.cellHeight(at: 0, tableViewWidth: 432)

        //then
        // ширина картинки 432 - 32 = 400, масштаб 2, высота 100 * 2 + 8
        XCTAssertEqual(height, 208, accuracy: 0.001)
    }

    func testPresenterUpdatesLikeOnSuccess() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let imageListService = ImageListServiceStub()
        let presenter = makePresenterWithPhotos(count: 2, imageListService: imageListService)
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        presenter.didTapLike(at: 1)

        //then
        XCTAssertTrue(viewController.showLoadingIndicatorCalled)
        XCTAssertTrue(viewController.hideLoadingIndicatorCalled)
        XCTAssertTrue(viewController.setIsLikedCalled)
        XCTAssertEqual(viewController.likedIndex, 1)
        XCTAssertEqual(viewController.isLiked, true)
        XCTAssertTrue(presenter.photo(at: 1).isLiked)
        XCTAssertFalse(viewController.showLikeErrorAlertCalled)
    }

    func testPresenterShowsErrorOnLikeFailure() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let imageListService = ImageListServiceStub()
        imageListService.changeLikeResult = .failure(NetworkError.invalidRequest)
        let presenter = makePresenterWithPhotos(count: 2, imageListService: imageListService)
        viewController.presenter = presenter
        presenter.view = viewController

        //when
        presenter.didTapLike(at: 1)

        //then
        XCTAssertTrue(viewController.showLoadingIndicatorCalled)
        XCTAssertTrue(viewController.hideLoadingIndicatorCalled)
        XCTAssertTrue(viewController.showLikeErrorAlertCalled)
        XCTAssertFalse(viewController.setIsLikedCalled)
        XCTAssertFalse(presenter.photo(at: 1).isLiked)
    }

    // MARK: - Helpers

    private func makePhoto(id: String, size: CGSize = CGSize(width: 100, height: 100), isLiked: Bool = false) -> PhotoViewModel {
        PhotoViewModel(
            id: id,
            size: size,
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/thumb_\(id).jpg",
            largeImageURL: "https://images.unsplash.com/large_\(id).jpg",
            isLiked: isLiked
        )
    }

    private func makePresenterWithPhotos(count: Int, imageListService: ImageListServiceStub) -> ImagesListPresenter {
        let presenter = ImagesListPresenter(imageListService: imageListService)
        presenter.viewDidLoad()
        imageListService.photos = (0..<count).map { makePhoto(id: "\($0)") }
        NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
        return presenter
    }
}
