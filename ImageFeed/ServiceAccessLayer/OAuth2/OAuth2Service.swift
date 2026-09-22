//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Adilkhan on 20/9/26.
//

import Foundation

enum OAuth2Constants {
    static let tokenURL = "https://unsplash.com/oauth/token"
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let decoder = JSONDecoder()
    private let storage = OAuth2TokenStorage()
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let urlRequest = makeTokenRequest(code: code) else {
            print("[OAuth2Service.fetchOAuthToken]: invalidRequest - не удалось собрать запрос")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let token = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.storage.accessToken = token.access_token
                    completion(.success(token.access_token))
                }
                catch {
                    print("[OAuth2Service.fetchOAuthToken]: decodingError - \(error), url: \(OAuth2Constants.tokenURL)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: \(error), url: \(OAuth2Constants.tokenURL)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func makeTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuth2Constants.tokenURL) else {
            print("[OAuth2Service.makeTokenRequest]: invalidRequest - не удалось создать URLComponents из строки \(OAuth2Constants.tokenURL)")
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
            print("[OAuth2Service.makeTokenRequest]: invalidRequest - не удалось получить URL из URLComponents \(urlComponents)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
