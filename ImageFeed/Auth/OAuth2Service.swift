//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Adilkhan on 20/9/26.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let decoder = JSONDecoder()
    
    private let storage: UserDefaults = .standard
    
    var accessToken: String? {
        get { storage.string(forKey: "access_token") }
        set { storage.set(newValue, forKey: "access_token") }
    }
    
    private init() {}
    
    func fetchOAuthToken(code: String) {
        guard let urlRequest = makeTokenRequest(code: code) else { return }
        
        let task = URLSession.shared.data(for: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let token = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.accessToken = token.access_token
                }
                catch {
                    print("Decode error: \(error)")
                }
            case .failure(let error):
            print("Network error: \(error)")
            }
        }
        task.resume()
    }
    
    private func makeTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: AuthViewConstants.tokenURL) else {
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
        request.httpMethod = "POST"
        return request
    }
    
    
}
