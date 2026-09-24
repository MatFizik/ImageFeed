//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Adilkhan on 23/9/26.
//

import Foundation
import SwiftKeychainWrapper
internal import CoreGraphics

final class ImageListService {
    static var shared = ImageListService()
    private init() {}
    
    private var fetchPhotosTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    
    private(set) var photos: [PhotoViewModel] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    
    private var lastLoadedPage: Int?
    
    func clearPhotosData() {
        photos.removeAll()
    }
    
    // MARK: -GetRequestFetchPhotosNextPage
    func fetchPhotosNextPage() {
        guard fetchPhotosTask?.state != .running else {return}
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makeRequestFetchPhotosNextPage(nextPage) else {return}
        
        let task = URLSession.shared.objectTask(for: request) {[weak self] (result: Result<[PhotoResponseModel], Error>) in
            
            switch result {
            case .success(let listData):
                for data in listData {
                    guard let photoViewModel = self?.convert(model: data) else {return}
                    self?.photos.append(photoViewModel)
                }
                
                self?.lastLoadedPage = nextPage
                
                NotificationCenter.default
                    .post(
                        name: ImageListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self?.photos as Any]
                    )
                
            case .failure(_):
                AppLogger.error("Ошибка получения фотографий")
            }
            self?.fetchPhotosTask = nil
        }
        self.fetchPhotosTask = task
        task.resume()
    }
    
    //MARK: -GetRequestChangeLike
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard likeTask == nil else {return}
        guard let request = makeRequestChangeLike(photoId, isLike) else {return}
        
        let task = URLSession.shared.data(for: request) {[weak self] result in
            guard let self else {return}
            
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                   let photo = self.photos[index]
                   let newPhoto = PhotoViewModel(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                completion(.success(()))
            case .failure(let error):
                AppLogger.error("Ошибка в методе changeLike", metadata: ["from":"ImageListService","Error": "\(error)"])
                    completion(.failure(error))
            }
            self.likeTask = nil
        }
        self.likeTask = task
        task.resume()
    }
    
    // MARK: -MakeRequestChangeLike
    private func makeRequestChangeLike(_ photoId: String, _ isDelete: Bool) -> URLRequest? {
        guard let urlComponents = URLComponents(string:
                                                    "\(Constants.defaultBaseURLString)/photos/\(photoId)/like") else {
            AppLogger.error("Ошибка формирования URLComponents", metadata: ["from":"makeRequestChangeLike"], category: LogCategory.request)
            return nil
        }
        guard let url = urlComponents.url else {
            AppLogger.error("Ошибка: не удалось получить URL", metadata: ["from":"makeRequestChangeLike"], category: LogCategory.request)
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = isDelete ? HTTPMethod.delete.rawValue : HTTPMethod.post.rawValue
        
        guard let accessToken = KeychainWrapper.standard.string(forKey: Constants.keyAccessToken) else {
            AppLogger.error("Ошибка при получении токена", metadata: ["from":"makeRequestFetchPhotosNextPage"], category: LogCategory.request)
            return nil}
        
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    // MARK: -MakeRequestFetchPhotosNextPage
    private func makeRequestFetchPhotosNextPage(_ page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "\(Constants.defaultBaseURLString)/photos") else {
            AppLogger.error("Ошибка формирования URLComponents", metadata: ["from":"makeRequestFetchPhotosNextPage"], category: LogCategory.request)
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
        ]
        
        guard let url = urlComponents.url else {
            AppLogger.error("Ошибка: не удалось получить URL", metadata: ["from":"makeRequestFetchPhotosNextPage"], category: LogCategory.request)
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        
        guard let accessToken = KeychainWrapper.standard.string(forKey: Constants.keyAccessToken) else {
            AppLogger.error("Ошибка при получении токена", metadata: ["from":"makeRequestFetchPhotosNextPage"], category: LogCategory.request)
            return nil}
        
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    //MARK: -Конвертация модели во viewModel
    private func convert(model: PhotoResponseModel) -> PhotoViewModel {
        PhotoViewModel(
            id: model.id,
            size: CGSize(width: model.width,
                         height: model.height),
            createdAt: model.createdAt,
            welcomeDescription: model.welcomeDescription,
            thumbImageURL: model.urls.thumb,
            largeImageURL: model.urls.regular,
            isLiked: model.isLiked
        )
    }
}

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        copy[index] = newValue
        return copy
    }
}
