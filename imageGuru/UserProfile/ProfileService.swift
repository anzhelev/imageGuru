//
//  ProfileService.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.03.2024.
//
import Foundation

struct ProfileRequestResult: Decodable {
    var username: String
    var firstName: String
    var lastName: String?
    var bio: String?
}

struct ProfileImageRequestResult: Decodable {
    var profileImage: URL?
}

struct Profile {
    var username: String
    var name: String
    var loginName: String
    var bio: String?
    var profileImage: URL?
}

final class ProfileService {
    
    // MARK: - Private Properties
    private enum FetchProfileData: Error {
        case invalidRequest
        case dataTaskError
        case tokenRequestError
        case dataError
        case JSONDecodeError
    }
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
        
    var fetchProfileTask: URLSessionTask?
    
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchUserProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
if fetchProfileTask != nil {
    fetchProfileTask?.cancel()
        }
        
        var userProfile = Profile(
            username: "",
            name: "",
            loginName: ""
        )
        
        let userProfileRequestUrl = "https://api.unsplash.com/me"

        guard let request = makeUserProfileDataRequest(userProfileRequestUrl, tokenIsNeeded: true) else {
            completion(.failure(FetchProfileData.invalidRequest))
            return
        }
        
        var fetchProfileTask = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if error != nil {
                completion(.failure(FetchProfileData.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(FetchProfileData.tokenRequestError))
                return
            }
            
            guard let data = data
            else {
                completion(.failure(FetchProfileData.dataError))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let profileData = try decoder.decode(ProfileRequestResult.self, from: data)
                
                userProfile.username = profileData.username
                userProfile.name = profileData.lastName != nil ? "\(profileData.firstName) \(String(describing: profileData.lastName))" : "\(profileData.firstName)"
                userProfile.loginName = "@\(profileData.username)"
                userProfile.bio = profileData.bio
                
            } catch _ {
                completion(.failure(FetchProfileData.JSONDecodeError))
                return
            }
        }
        
        fetchProfileTask.resume()
        
        let userProfilePImageRequestUrl = "https://api.unsplash.com/users/:\(userProfile.username)"
        
        guard let request = makeUserProfileDataRequest(userProfilePImageRequestUrl, tokenIsNeeded: false) else {
            completion(.failure(FetchProfileData.invalidRequest))
            return
        }
        
        fetchProfileTask = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if error != nil {
                completion(.failure(FetchProfileData.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(FetchProfileData.tokenRequestError))
                return
            }
            
            guard let data = data
            else {
                completion(.failure(FetchProfileData.dataError))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let profileData = try decoder.decode(ProfileImageRequestResult.self, from: data)
                
                userProfile.profileImage = profileData.profileImage
                
                completion(.success(userProfile))
                
            } catch _ {
                completion(.failure(FetchProfileData.JSONDecodeError))
                return
            }
        }
        
        self.fetchProfileTask = fetchProfileTask
        fetchProfileTask.resume()
    }
    
    // MARK: - Private Methods
    private func makeUserProfileDataRequest(_ url: String, tokenIsNeeded: Bool) -> URLRequest? {
        
        guard let url = URL(string: url) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeUserProfileRequest: Ошибка создания URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        if tokenIsNeeded {
            guard let authToken = oauth2TokenStorage.token else {
                assertionFailure("Failed to create URL: Invalid Token")
                print("CONSOLE func makeUserProfileRequest: неверный токен")
                return nil
            }
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "GET"
        return request
    }
    
}
