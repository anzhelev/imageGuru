//
//  OAuth2Service.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 12.03.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    var accessToken: String
}

final class OAuth2Service {
    
    // MARK: - Public Properties
    static let shared = OAuth2Service()
    var task: URLSessionTask?
    var lastCode: String?
    
    // MARK: - Private Properties
    /// кейсы возможных ошибок при запросе токена
    private enum FetchOAuthTokenErrors: Error {
        case requestOverlap
        case requestCreationError
    }
    
    private let dataLoader = DataLoader()
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code {
            completion(.failure(FetchOAuthTokenErrors.requestOverlap))
            return
        } else if task != nil {
            task?.cancel()
            print("CONSOLE func fetchOAuthToken: Отмена предыдущего незавершенного сетевого запроса.")
        }
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(FetchOAuthTokenErrors.requestCreationError))
            return
        }
        
        let task = dataLoader.objectTask(for: request) {(result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let token):
                completion(.success(token.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        guard let baseURL = URL(string: "https://unsplash.com"),
              let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.accessKey)"
                + "&&client_secret=\(Constants.secretKey)"
                + "&&redirect_uri=\(Constants.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                relativeTo: baseURL
              ) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeOAuthTokenRequest: Ошибка сборки URL для запроса токена")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
