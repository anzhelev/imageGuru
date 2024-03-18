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
    
    // MARK: - Private Properties
    private enum FetchOAuthToken: Error {
        case URLSessionDataTaskError
        case tokenRequestError
        case dataError
        case JSONDecodeError
    }
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("CONSOLE func fetchOAuthToken Ошибка создания запроса токена")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if error != nil {
                completion(.failure(FetchOAuthToken.URLSessionDataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(FetchOAuthToken.tokenRequestError))
                return
            }
            
            guard let data = data
            else {
                completion(.failure(FetchOAuthToken.dataError))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let token = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                completion(.success(token.accessToken))
            } catch _ {
                completion(.failure(FetchOAuthToken.JSONDecodeError))
                return
            }
        }
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
            print("CONSOLE func makeOAuthTokenRequest Ошибка создания URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
