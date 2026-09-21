//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Adilkhan on 21/9/26.
//

import Foundation

final class ProfileService {
    static var shared = ProfileService()
    private let tokenStorage = OAuth2TokenStorage()
    
    private var task: URLSessionTask?
    
    private let decoder = JSONDecoder()
    
    private(set) var profileViewModel: ProfileViewModel?
    
    private init() {}
    
    //MARK: -Запрос за базовой инфой профиля
    func fetchBaseProfile(completion: @escaping (Result<ProfileViewModel, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeRequest() else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.data(for: request) {[weak self] result in
            switch result {
            case .success(let data):
                do{
                    guard let profileData = try self?.decoder.decode(ProfileResponseModel.self, from: data) else {
                        return
                    }
                    guard let profileViewData = self?.convert(model: profileData) else {return}
                    self?.profileViewModel = profileViewData
                    completion(.success(profileViewData))
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
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
        urlRequest.httpMethod = "GET"
        guard let accessToken = tokenStorage.accessToken else { return nil }
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
