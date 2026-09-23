//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Adilkhan on 20/9/26.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    AppLogger.info("Полученные данные", metadata: ["from": "objectTask", "Data": jsonString])
                }
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    if let decodingError = error as? DecodingError {
                        AppLogger.error("Ошибка декодирования",
                                        metadata: ["from": "objectTask",
                                                   "Error": "\(decodingError)",
                                                   "Data": "\(String(data: data, encoding: .utf8) ?? "")"], category: LogCategory.decoding)
                    } else {
                        AppLogger.error("Ошибка декодирования",
                                        metadata: ["from": "objectTask",
                                                   "Error": "\(error.localizedDescription)",
                                                   "Data": " \(String(data: data, encoding: .utf8) ?? "")"])
                    }
                    completion(.failure(error))
                }
            case .failure(let error):
                AppLogger.error("Ошибка запроса", metadata: ["from": "objectTask",
                                                             "Error": "\(error.localizedDescription)"], category: LogCategory.request)
                completion(.failure(error))
            }
        }
        return task
    }
}
