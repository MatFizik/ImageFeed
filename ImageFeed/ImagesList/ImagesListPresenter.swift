//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Adilkhan on 28/9/26.
//

import Foundation
internal import CoreGraphics

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at index: Int) -> PhotoViewModel
    func cellHeight(at index: Int, tableViewWidth: CGFloat) -> CGFloat
    func willDisplayCell(at index: Int)
    func didTapLike(at index: Int)
}

protocol ImageListServiceProtocol {
    var photos: [PhotoViewModel] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

extension ImageListService: ImageListServiceProtocol {}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    private let imageListService: ImageListServiceProtocol

    private var photos: [PhotoViewModel] = []

    private var imageListServiceObserver: NSObjectProtocol?

    var photosCount: Int {
        photos.count
    }

    init(imageListService: ImageListServiceProtocol = ImageListService.shared) {
        self.imageListService = imageListService
    }

    nonisolated deinit {}

    func viewDidLoad() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updatePhotos()
            }
        imageListService.fetchPhotosNextPage()
    }

    func photo(at index: Int) -> PhotoViewModel {
        photos[index]
    }

    func cellHeight(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        let size = photos[index].size

        let horizontalInsets: CGFloat = 16 + 16
        let verticalInsets: CGFloat = 4 + 4

        let imageViewWidth = tableViewWidth - horizontalInsets
        let scale = imageViewWidth / size.width
        return size.height * scale + verticalInsets
    }

    func willDisplayCell(at index: Int) {
        if index + 1 == photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }

    func didTapLike(at index: Int) {
        let photo = photos[index]
        view?.showLoadingIndicator()
        imageListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            self.view?.hideLoadingIndicator()

            switch result {
            case .success:
                guard
                    let updatedPhoto = self.imageListService.photos.first(where: { $0.id == photo.id }),
                    let index = self.photos.firstIndex(where: { $0.id == photo.id })
                else { return }
                self.photos = self.photos.withReplaced(itemAt: index, newValue: updatedPhoto)
                self.view?.setIsLiked(updatedPhoto.isLiked, at: index)
            case .failure:
                self.view?.showLikeErrorAlert()
            }
        }
    }

    private func updatePhotos() {
        photos = imageListService.photos
        view?.updateTableViewAnimated()
    }
}
