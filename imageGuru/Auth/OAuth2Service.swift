//
//  OAuth2Service.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 12.03.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    var access_token: String
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private enum FetchOAuthToken: Error {
        case URLSessionDataTaskError
        case tokenRequestError
        case dataError
        case JSONDecodeError
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest {
        
        guard let baseURL = URL(string: "https://unsplash.com"),
              let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.AccessKey)"
                + "&&client_secret=\(Constants.SecretKey)"
                + "&&redirect_uri=\(Constants.RedirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                relativeTo: baseURL
              ) else {
            print("CONSOLE func makeOAuthTokenRequest Ошибка создания URL")
            return URLRequest(url: Constants.DefaultBaseURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let request = makeOAuthTokenRequest(code: code)
        
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
                let token = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                completion(.success(token.access_token))
            } catch _ {
                completion(.failure(FetchOAuthToken.JSONDecodeError))
                return
            }
        }
        task.resume()
    }
}
