//
//  ImageListServiceStub.swift
//  ImageFeedTests
//
//  Created by Adilkhan on 28/9/26.
//

@testable import ImageFeed
import Foundation

@MainActor
final class ImageListServiceStub: ImageListServiceProtocol {
    var photos: [PhotoViewModel] = []

    var fetchPhotosNextPageCallsCount: Int = 0

    var changeLikeResult: Result<Void, Error> = .success(())

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCallsCount += 1
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        if case .success = changeLikeResult,
           let index = photos.firstIndex(where: { $0.id == photoId }) {
            let photo = photos[index]
            photos[index] = PhotoViewModel(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                welcomeDescription: photo.welcomeDescription,
                thumbImageURL: photo.thumbImageURL,
                largeImageURL: photo.largeImageURL,
                isLiked: !photo.isLiked
            )
        }
        completion(changeLikeResult)
    }
}
