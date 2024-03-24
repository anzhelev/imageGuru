//
//  ProfileService.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.03.2024.
//
import Foundation

// структура данных ответа сервера на запрос общей информации профиля
struct ProfileRequestResult: Decodable {
    var username: String
    var firstName: String
    var lastName: String?
    var bio: String?
}

// структура данных ответа сервера на запрос фото профиля
struct ProfileImageRequestResult: Decodable {
    enum RootKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
    enum NestedKeys: String, CodingKey {
        case small, medium, large
    }
    let smallPicture: URL?
    let mediumPicture: URL?
    let largePicture: URL?
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        let nested = try root.nestedContainer(keyedBy: NestedKeys.self, forKey: .profileImage)
        smallPicture = try nested.decode(URL?.self, forKey: .small)
        mediumPicture = try nested.decode(URL?.self, forKey: .medium)
        largePicture = try nested.decode(URL?.self, forKey: .large)
    }
}

// структура данных для сохранения данных профиля пользователя
struct Profile {
    var username: String
    var name: String
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
    private enum FetchProfileData: Error {
        case invalidRequest
        case dataTaskError
        case tokenRequestError
        case dataError
        case JSONDecodeError
    }
    
    private(set) var profile: Profile?
     var fetchProfileTask: URLSessionTask?
    
    
    // MARK: - Initializers
    private init() {
        self.profile = Profile(username: "", name: "", loginName: "")
    }
    
    // MARK: - Public Methods
    func updateProfileDetails(userToken: String) {
        self.fetchUserProfileData(token: userToken) {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.fetchProfileTask = nil
                    self.profile = profile
                    print("CONSOLE ", self.profile as Any)
                    UIBlockingProgressHUD.dismiss()
//                    self.fetchUserProfilePicture(username: profile.username, token: userToken) {result in
//                        DispatchQueue.main.async {
//                            UIBlockingProgressHUD.dismiss()
//                            switch result {
//                            case .success(let profile):
//                                self.profile.smallProfileImage = profile.smallProfileImage
//                                print("CONSOLE ", self.profile)
//                                self.fetchProfileTask = nil
//                            case .failure(let error):
//                                print("CONSOLE func fetchUserProfilePicture: ", error.localizedDescription)
//                            }
//                        }
//                    }
                case .failure(let error):
                    print("CONSOLE func fetchUserProfileData: ", error.localizedDescription)
                    print("CONSOLE func fetchUserProfileData: Ошибка при запросе общих данных пользователя")
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
            print("CONSOLE func fetchUserProfileData: Ошибка - повторный запрос")
        }
        
        var userProfile = Profile(
            username: "",
            name: "",
            loginName: ""
        )
        
        let userProfileRequestUrl = "https://api.unsplash.com/me"
        
        
        guard let request = makeUserProfileDataRequest(token: token, url: userProfileRequestUrl) else {
            print("CONSOLE func fetchUserProfileData: ошибка 0")
            completion(.failure(FetchProfileData.invalidRequest))
            return
        }
        print("CONSOLE func fetchUserProfileData: Запрашиваем данные пользователя", request.allHTTPHeaderFields as Any)
        let fetchProfileTask = URLSession.shared.dataTask(with: request) {data, response, error in
            print("CONSOLE func fetchUserProfileData: Данные профиля пользователя запрошены")
            if error != nil {
                print("CONSOLE func fetchUserProfileData: ошибка 1", error as Any)
                completion(.failure(FetchProfileData.dataTaskError))
                return
            }
            print("CONSOLE func fetchUserProfileData: Ошибки 1 не было")
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("CONSOLE func fetchUserProfileData: ", response as Any)
                print("CONSOLE func fetchUserProfileData: ошибка 2 ", response.statusCode)
                completion(.failure(FetchProfileData.tokenRequestError))
                return
            }
            print("CONSOLE func fetchUserProfileData: ", response as Any)
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
                print("CONSOLE func fetchUserProfileData: ошибка 3")
                completion(.failure(FetchProfileData.JSONDecodeError))
                return
            }
        }
//        self.fetchProfileTask = fetchProfileTask
        fetchProfileTask.resume()
    }
    
    /// функция получения фото профиля пользователя
    private func fetchUserProfilePicture(username: String, token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
//        if fetchProfileTask != nil {
//            fetchProfileTask?.cancel()
//        }
//        
        var userProfile = Profile(
            username: username,
            name: "",
            loginName: ""
        )
        
        let userProfileImageRequestUrl = "https://api.unsplash.com/users \(username)"
        
        guard let request = makeUserProfileDataRequest(token: token, url: userProfileImageRequestUrl) else {
            print("CONSOLE func fetchUserProfileData: ошибка 4")
            completion(.failure(FetchProfileData.invalidRequest))
            return
        }
        
        _ = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if error != nil {
                print("CONSOLE func fetchUserProfileData: ошибка 5")
                completion(.failure(FetchProfileData.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("CONSOLE func fetchUserProfileData: ошибка 6")
                completion(.failure(FetchProfileData.tokenRequestError))
                return
            }
            
            guard let data = data
            else {
                print("CONSOLE func fetchUserProfileData: ошибка 7")
                completion(.failure(FetchProfileData.dataError))
                return
            }
            do {
                let decoder = JSONDecoder()
                //                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let profileData = try decoder.decode(ProfileImageRequestResult.self, from: data)
                
                userProfile.smallProfileImage = profileData.smallPicture
                userProfile.mediumProfileImage = profileData.mediumPicture
                userProfile.largeProfileImage = profileData.largePicture
                
                completion(.success(userProfile))
                
            } catch _ {
                print("CONSOLE func fetchUserProfileData: ошибка 8")
                completion(.failure(FetchProfileData.JSONDecodeError))
                return
            }
        }
//        
//        self.fetchProfileTask = fetchProfileTask
//        fetchProfileTask.resume()
    }
    
    
    /// функция сбора запроса для получения данных профиля пользователя
    private func makeUserProfileDataRequest(token: String, url: String) -> URLRequest? {
        
        guard let url = URL(string: url) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeUserProfileRequest: Ошибка создания URL")
            return nil
        }

        var request = URLRequest(url: url)
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
        print("CONSOLE func makeUserProfileRequest: ", request.url as Any, token)
        request.httpMethod = "GET"
        return request
    }
}
