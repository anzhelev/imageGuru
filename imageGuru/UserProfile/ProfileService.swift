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
    
    //    private let splashViewController = SplashViewController()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private(set) var profile: Profile
    private var fetchProfileTask: URLSessionTask?
    
    
    // MARK: - Initializers
    private init() {
        self.profile = Profile(username: "", name: "", loginName: "")
    }
    
    // MARK: - Public Methods
    func updateProfileDetails() {
        self.fetchUserProfile() {result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let profile):
                    self.profile = profile
                    self.fetchProfileTask = nil
                    //                    self.splashViewController.switchToTabBarController()
                case .failure(let error):
                    print("CONSOLE func updateProfileDetails: ", error.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK: - Private Methods
    private func fetchUserProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if fetchProfileTask != nil {
            fetchProfileTask?.cancel()
        }
        
        var userProfile = Profile(
            username: "anzhelev",
            name: "",
            loginName: ""
        )
        
        let userProfileRequestUrl = "https://api.unsplash.com/me"
        
        guard let request = makeUserProfileDataRequest(userProfileRequestUrl) else {
            completion(.failure(FetchProfileData.invalidRequest))
            return
        }
        
        var fetchProfileTask = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if error != nil {
                print("CONSOLE func updateProfileDetails: ошибка 1")
                completion(.failure(FetchProfileData.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("CONSOLE func updateProfileDetails: ошибка 2")
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
                print("CONSOLE func updateProfileDetails: ошибка 3")
                completion(.failure(FetchProfileData.JSONDecodeError))
                return
            }
        }
        
        fetchProfileTask.resume()
        
        let userProfileImageRequestUrl = "https://api.unsplash.com/users/\(userProfile.username)"
        
        guard let request = makeUserProfileDataRequest(userProfileImageRequestUrl) else {
            print("CONSOLE func updateProfileDetails: ошибка 4")
            completion(.failure(FetchProfileData.invalidRequest))
            return
        }
        
        fetchProfileTask = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if error != nil {
                print("CONSOLE func updateProfileDetails: ошибка 5")
                completion(.failure(FetchProfileData.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("CONSOLE func updateProfileDetails: ошибка 6")
                completion(.failure(FetchProfileData.tokenRequestError))
                return
            }
            
            guard let data = data
            else {
                print("CONSOLE func updateProfileDetails: ошибка 7")
                completion(.failure(FetchProfileData.dataError))
                return
            }
            do {
                let decoder = JSONDecoder()
                //                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let profileData = try decoder.decode(ProfileImageRequestResult.self, from: data)
                
                userProfile.smallProfileImage = profileData.smallPicture
                
                completion(.success(userProfile))
                
            } catch _ {
                print("CONSOLE func updateProfileDetails: ошибка 8")
                completion(.failure(FetchProfileData.JSONDecodeError))
                return
            }
        }
        
        self.fetchProfileTask = fetchProfileTask
        fetchProfileTask.resume()
    }
    
    
    private func makeUserProfileDataRequest(_ url: String) -> URLRequest? {
        
        guard let url = URL(string: url) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeUserProfileRequest: Ошибка создания URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        guard let authToken = oauth2TokenStorage.token else {
            assertionFailure("Failed to create URL: Invalid Token")
            print("CONSOLE func makeUserProfileRequest: неверный токен")
            return nil
        }
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        print(request.url as Any)
        request.httpMethod = "GET"
        return request
    }
    
}
