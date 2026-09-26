//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Adilkhan on 21/9/26.
//

import Foundation
import SwiftKeychainWrapper

final class ProfileService {
    static var shared = ProfileService()
    
    private var task: URLSessionTask?
    
    private let decoder = JSONDecoder()
    
    private(set) var profileViewModel: ProfileViewModel?
    
    func clearProfileData() {
        profileViewModel = nil
    }
    
    private init() {}
    
    //MARK: -Запрос за базовой инфой профиля
    func fetchBaseProfile(completion: @escaping (Result<ProfileViewModel, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeRequest() else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result:
                                                                                Result<ProfileResponseModel, Error>) in
            
            switch result {
            case .success(let data):
                guard let profileViewData = self?.convert(model: data) else {return}
                self?.profileViewModel = profileViewData
                completion(.success(profileViewData))
            case .failure(let error):
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
    
    //MARK: -Сборка реквеста
    private func makeRequest() -> URLRequest? {
        let uRLComponents = URLComponents(string: "\(Constants.defaultBaseURLString)/me")
        guard let url = uRLComponents?.url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        guard let accessToken = KeychainWrapper.standard.string(forKey: Constants.keyAccessToken) else { return nil }
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    //MARK: -Конвертация модели во viewModel
    private func convert(model: ProfileResponseModel) -> ProfileViewModel {
        ProfileViewModel(
            username: model.username,
            name: "\(model.firstName) \(model.lastName)",
            login: "@\(model.username)",
            bio: model.bio
        )
    }
}

