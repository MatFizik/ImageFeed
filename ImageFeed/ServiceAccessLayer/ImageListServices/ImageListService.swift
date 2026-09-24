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
    
    private var task: URLSessionTask?
    
    private(set) var photos: [PhotoViewModel] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    
    private var lastLoadedPage: Int?
    
    // MARK: -GetRequest
    func fetchPhotosNextPage() {
        guard task?.state != .running else {return}
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makeRequest(nextPage) else {return}
        
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
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: -MakeRequest
    private func makeRequest(_ page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "\(Constants.defaultBaseURLString)/photos") else {
            AppLogger.error("Ошибка формирования URLComponents", metadata: ["from":"ImageListService"], category: LogCategory.request)
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
        ]
        
        guard let url = urlComponents.url else {
            AppLogger.error("Ошибка: не удалось получить URL", metadata: ["from":"ImageListService"], category: LogCategory.request)
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        
        guard let accessToken = KeychainWrapper.standard.string(forKey: Constants.keyAccessToken) else {
            AppLogger.error("Ошибка при получении токена", metadata: ["from":"ImageListService"], category: LogCategory.request)
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
            isLiked: false
        )
    }
}

