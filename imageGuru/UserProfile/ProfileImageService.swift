//
//  ProfileImageService.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 26.03.2024.
//
import Foundation

/// структура данных ответа сервера на запрос url фото профиля
struct ProfileImageURLRequestResult: Decodable {
    enum RootKeys: String, CodingKey {
        case profileImage
    }
    enum NestedKeys: String, CodingKey {
        case small
    }
    
    let small: URL?
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        let nested = try root.nestedContainer(keyedBy: NestedKeys.self, forKey: .profileImage)
        small = try nested.decode(URL.self, forKey: .small)
    }
}


final class ProfileImageService {
    
    // MARK: - Public Properties
    static let profileImageService = ProfileImageService()
    
    // MARK: - Private Properties
    /// кейсы возможных ошибок при запросе данных профиля пользователя
    private enum FetchProfileData: Error {
        case invalidRequest
        case dataTaskError
        case userDataRequestError
        case receivedDataError
        case JSONDecodeError
        case profileImageURLLoadError
    }
    
    //    private(set) var profileImageURL: URL
    private let userProfile = ProfileService.profileService
    private (set) var avatarURL: URL?
    private var fetchProfileTask: URLSessionTask?
    
    
    // MARK: - Initializers
    private init() {
    }
    
    // MARK: - Public Methods
    /// функция обновления данных профиля пользователя
    func updateProfileDetails(userToken: String, completion: @escaping () -> Void) {
        self.fetchUserProfileImageURL(username: userProfile.profile.username, token: userToken) {result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let url):
                    self.avatarURL = url
                    self.fetchProfileTask = nil
                    completion()
                case .failure(let error):
                    print("CONSOLE func fetchUserProfilePicture: ", error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// функция получения url на фото профиля пользователя
    private func fetchUserProfileImageURL(username: String, token: String, completion: @escaping (Result<URL, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if fetchProfileTask != nil {
            fetchProfileTask?.cancel()
            print("CONSOLE func fetchUserProfileImageURL: Отмена предыдущего незавершенного сетевого запроса.")
        }
        
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
                let profileData = try decoder.decode(ProfileImageURLRequestResult.self, from: data)
                
                guard let profileImageURL = profileData.small else {
                    completion(.failure(FetchProfileData.profileImageURLLoadError))
                    return
                }
                
                completion(.success(profileImageURL))
                
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
