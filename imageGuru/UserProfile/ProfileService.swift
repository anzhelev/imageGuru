//
//  ProfileService.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.03.2024.
//
import Foundation

/// структура данных ответа сервера на запрос общей информации профиля
struct ProfileRequestResult: Decodable {
    var username: String
    var firstName: String
    var lastName: String?
    var bio: String?
}

/// структура данных ответа сервера на запрос url фото профиля
struct ProfileImageRequestResult: Decodable {
    enum RootKeys: String, CodingKey {
        case profileImage
    }
    enum NestedKeys: String, CodingKey {
        case small, medium, large
    }
    
    let small: URL?
    let medium: URL?
    let large: URL?
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        let nested = try root.nestedContainer(keyedBy: NestedKeys.self, forKey: .profileImage)
        small = try nested.decode(URL?.self, forKey: .small)
        medium = try nested.decode(URL?.self, forKey: .medium)
        large = try nested.decode(URL?.self, forKey: .large)
    }
}

/// структура данных для сохранения данных профиля пользователя
struct Profile {
    var username: String
    var firstName: String
    var lastName: String?
    var loginName: String
    var bio: String?
    var smallProfileImage: URL?
    var mediumProfileImage: URL?
    var largeProfileImage: URL?
}

final class ProfileService {
    
    // MARK: - Public Properties
    static let profileService = ProfileService()
    
    // MARK: - Private Properties
    /// кейсы возможных ошибок при запросе данных профиля пользователя
    private enum FetchProfileData: Error {
        case invalidRequest
        case dataTaskError
        case userDataRequestError
        case receivedDataError
        case JSONDecodeError
    }
    
    private(set) var profile: Profile
    private var fetchProfileTask: URLSessionTask?
    
    
    // MARK: - Initializers
    private init() {
        self.profile = Profile(username: "", firstName: "", loginName: "")
    }
    
    // MARK: - Public Methods
    /// функция обновления данных профиля пользователя
    func updateProfileDetails(userToken: String, completion: @escaping () -> Void) {
        self.fetchUserProfileData(token: userToken) {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.fetchProfileTask = nil
                    self.profile = profile
                    self.fetchUserProfileImage(username: profile.username, token: userToken) {result in
                        DispatchQueue.main.async {
                            UIBlockingProgressHUD.dismiss()
                            switch result {
                            case .success(let profile):
                                self.profile.smallProfileImage = profile.smallProfileImage
                                self.profile.mediumProfileImage = profile.mediumProfileImage
                                self.profile.largeProfileImage = profile.largeProfileImage
                                self.fetchProfileTask = nil
                                completion()
                            case .failure(let error):
                                print("CONSOLE func fetchUserProfilePicture: ", error.localizedDescription)
                            }
                        }
                    }
                case .failure(let error):
                    print("CONSOLE func fetchUserProfileData: ", error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    /// функция получения общих данных профиля пользователя
    private func fetchUserProfileData(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if (fetchProfileTask != nil) {
            fetchProfileTask?.cancel()
            print("CONSOLE func fetchUserProfileData: Отмена предыдущего незавершенного сетевого запроса.")
        }
        
        var userProfile = Profile(
            username: "",
            firstName: "",
            loginName: ""
        )
        
        let userProfileRequestUrl = "https://api.unsplash.com/me"
        guard let request = makeUserProfileDataRequest(token: token, url: userProfileRequestUrl) else {
            completion(.failure(FetchProfileData.invalidRequest))
            return
        }
        
        let fetchProfileTask = URLSession.shared.dataTask(with: request) {data, response, error in
            if error != nil {
                completion(.failure(FetchProfileData.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(FetchProfileData.userDataRequestError))
                return
            }
            
            guard let data = data
            else {
                completion(.failure(FetchProfileData.receivedDataError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let profileData = try decoder.decode(ProfileRequestResult.self, from: data)
                
                userProfile.username = profileData.username
                userProfile.firstName = profileData.firstName
                userProfile.lastName = profileData.lastName
                userProfile.loginName = "@\(profileData.username)"
                userProfile.bio = profileData.bio
                
                completion(.success(userProfile))
                
            } catch _ {
                completion(.failure(FetchProfileData.JSONDecodeError))
                return
            }
        }
        self.fetchProfileTask = fetchProfileTask
        fetchProfileTask.resume()
    }
    
    /// функция получения url на фото профиля пользователя
    private func fetchUserProfileImage(username: String, token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if fetchProfileTask != nil {
            fetchProfileTask?.cancel()
            print("CONSOLE func fetchUserProfileImage: Отмена предыдущего незавершенного сетевого запроса.")
        }
        
        var userProfile = Profile(
            username: username,
            firstName: "",
            loginName: ""
        )
        
        let userProfileImageRequestUrl = "https://api.unsplash.com/users/\(username)"
        guard let request = makeUserProfileDataRequest(token: token, url: userProfileImageRequestUrl) else {
            completion(.failure(FetchProfileData.invalidRequest))
            return
        }
        
        let fetchProfileTask = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if error != nil {
                completion(.failure(FetchProfileData.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(FetchProfileData.userDataRequestError))
                return
            }
            
            guard let data = data
            else {
                completion(.failure(FetchProfileData.receivedDataError))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let profileData = try decoder.decode(ProfileImageRequestResult.self, from: data)
                
                userProfile.smallProfileImage = profileData.small
                userProfile.mediumProfileImage = profileData.medium
                userProfile.largeProfileImage = profileData.large
                
                completion(.success(userProfile))
                
            } catch _ {
                completion(.failure(FetchProfileData.JSONDecodeError))
                return
            }
        }
        
        self.fetchProfileTask = fetchProfileTask
        fetchProfileTask.resume()
    }
    
    /// функция сбора запроса для получения данных профиля пользователя
    private func makeUserProfileDataRequest(token: String, url: String) -> URLRequest? {
        
        guard let url = URL(string: url) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeUserProfileDataRequest: Ошибка создания URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        return request
    }
}
