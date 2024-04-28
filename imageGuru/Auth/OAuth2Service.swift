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
    static let oAuth2Service = OAuth2Service()
    static var authorizationFailed: Bool = false
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
    /// функция сетевого запроса для получения токена
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code {
            completion(.failure(FetchOAuthTokenErrors.requestOverlap))
            return
        } else if task != nil {
            task?.cancel()
            print("CONSOLE func fetchOAuthToken: Отмена предыдущего незавершенного запроса.")
        }
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(FetchOAuthTokenErrors.requestCreationError))
            return
        }
        
        let task = dataLoader.objectTask(for: request) {(result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                OAuth2Service.oAuth2Service.task = nil
                OAuth2Service.oAuth2Service.lastCode = nil
                switch result {
                case .success(let token):
                    OAuth2TokenStorage.token = token.accessToken
                    completion(.success(token.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.task = task
    }
    
    // MARK: - Private Methods
    /// функция сборки запроса для загрузки токена
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
