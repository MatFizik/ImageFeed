//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Adilkhan on 20/9/26.
//

import Foundation
import SwiftKeychainWrapper

enum OAuth2Constants {
    static let tokenURL = "https://unsplash.com/oauth/token"
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var task: URLSessionTask?
    
    private let decoder = JSONDecoder()
    
    private var lastCode: String?
    
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        lastCode = code
        guard
            let request = makeTokenRequest(code: code)
        else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result:
            Result<OAuthTokenResponseBody, Error>) in
            
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                
                switch result {
                case .success(let body):
                    let isSuccess = KeychainWrapper.standard.set(body.accessToken, forKey: Constants.keyAccessToken)
                    guard isSuccess else {
                        AppLogger.error("Keychain save error", metadata: ["metadataKey": "fetchOAuthToken"])
                        return
                    }
                    completion(.success("success"))
                    
                case .failure(let error):
                    AppLogger.error("Ошибка запроса: \(error.localizedDescription)", metadata: ["metadataKey": "fetchOAuthToken","Error": "\(error)"], category: LogCategory.request)
                    completion(.failure(error))
                }
                
                self.task = nil
                self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    private func makeTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuth2Constants.tokenURL) else {
           return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
