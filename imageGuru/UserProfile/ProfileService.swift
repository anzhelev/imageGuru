//
//  ProfileService.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.03.2024.
//
import Foundation

/// структура данных для сохранения данных профиля пользователя
struct Profile {
    var username: String
    var firstName: String
    var lastName: String?
    var loginName: String
    var bio: String?
}

final class ProfileService {
    
    // MARK: - Public Properties
    static let profileService = ProfileService()
    
    // MARK: - Private Properties
    /// структура данных ответа сервера на запрос общей информации профиля
    private struct ProfileRequestResult: Decodable {
        var username: String
        var firstName: String
        var lastName: String?
        var bio: String?
    }
    
    /// кейсы возможных ошибок при запросе данных профиля пользователя
    private enum FetchProfileDataErrors: Error {
        case requestCreationError
    }
    
    private(set) var profile: Profile
    private let dataLoader = DataLoader()
    private var task: URLSessionTask?
    
    // MARK: - Initializers
    private init() {
        self.profile = Profile(username: "", firstName: "", loginName: "")
    }
    
    // MARK: - Public Methods
    /// функция обновления данных профиля пользователя
    func updateProfileDetails(userToken: String, completion: @escaping (Bool) -> Void) {
        self.fetchUserProfileData(token: userToken) {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.profile.username = profile.username
                    self.profile.firstName = profile.firstName
                    self.profile.lastName = profile.lastName
                    self.profile.loginName = "@\(profile.username)"
                    self.profile.bio = profile.bio
                    self.task = nil
                    completion(true)
                case .failure(let error):
                    print("CONSOLE func fetchUserProfileData:", error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
    
    func cleanUserPofile() {
        profile = Profile(username: "",
                          firstName: "",
                          lastName: nil,
                          loginName: "",
                          bio: nil
        )
    }    
    
    // MARK: - Private Methods
    /// функция получения общих данных профиля пользователя
    private func fetchUserProfileData(token: String, completion: @escaping (Result<ProfileRequestResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            task?.cancel()
            print("CONSOLE func fetchUserProfileData: Отмена незавершенного запроса данных профиля.")
        }
        
        let userProfileRequestUrl = "https://api.unsplash.com/me"
        guard let request = makeUserProfileDataRequest(token: token, url: userProfileRequestUrl) else {
            completion(.failure(FetchProfileDataErrors.requestCreationError))
            return
        }
        
        let task = dataLoader.objectTask(for: request) {(result: Result<ProfileRequestResult, Error>) in
            switch result {
            case .success(let userData):
                completion(.success(userData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
    }
    
    /// функция сборки запроса для получения данных профиля пользователя
    private func makeUserProfileDataRequest(token: String, url: String) -> URLRequest? {
        guard let url = URL(string: url) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeUserProfileDataRequest: Ошибка сборки URL для запроса данных профиля пользователя")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
