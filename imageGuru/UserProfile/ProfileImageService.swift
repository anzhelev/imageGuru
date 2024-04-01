//
//  ProfileImageService.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 26.03.2024.
//
import UIKit
import Foundation

final class ProfileImageService {
    
    // MARK: - Public Properties
    static let profileImageService = ProfileImageService()
    
    // MARK: - Private Properties
    /// структура данных ответа сервера на запрос url фото профиля
    private struct ProfileImageURLRequestResult: Decodable {
        enum RootKeys: String, CodingKey {
            case profileImage
        }
        enum NestedKeys: String, CodingKey {
            case large
        }
        let large: URL?
        init(from decoder: Decoder) throws {
            let root = try decoder.container(keyedBy: RootKeys.self)
            let nested = try root.nestedContainer(keyedBy: NestedKeys.self, forKey: .profileImage)
            large = try nested.decode(URL.self, forKey: .large)
        }
    }
    
    /// кейсы возможных ошибок при запросе данных профиля пользователя
    private enum FetchProfileImageUrlErrors: Error {
        case requestCreationError
    }
    
    private let userProfile = ProfileService.profileService
    private (set) var avatarURL: URL? {
        didSet {
            print("CONSOLE avatarURL:", avatarURL?.absoluteString ?? "")
        }
    }
//    private (set) var avatarURL2: String = ""
    private let dataLoader = DataLoader()
    private var task: URLSessionTask?
    
    // MARK: - Initializers
    private init() {
        //        avatarURL = nil
    }
    
    // MARK: - Public Methods
    /// функция обновления данных профиля пользователя
    func updateProfileImageURL(userToken: String, completion: @escaping () -> Void) {
        self.fetchUserProfileImageURL(username: userProfile.profile.username, token: userToken) {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let avatar):
                    self.avatarURL = avatar
                    completion()
                case .failure(let error):
                    print("CONSOLE func fetchUserProfileImageURL:", error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// функция получения url на фото профиля пользователя
    private func fetchUserProfileImageURL(username: String, token: String, completion: @escaping (Result<URL, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            print("CONSOLE func fetchUserProfileImageURL: Отмена повторного сетевого запроса URL аватара для : \(username).")
            return
        }
        
        let userProfileImageRequestUrl = "https://api.unsplash.com/users/\(username)"
        guard let request = makeUserProfileImageUrlRequest(token: token, url: userProfileImageRequestUrl) else {
            completion(.failure(FetchProfileImageUrlErrors.requestCreationError))
            return
        }
        
        let task = dataLoader.objectTask(for: request) {(result: Result<ProfileImageURLRequestResult, Error>) in
            switch result {
            case .success(let url):
                guard let userImageURL = url.large
                else {
                    return
                }
                completion(.success(userImageURL))
                NotificationCenter.default.post(name: .userImageUrlUpdated,
                                                object: self,
                                                userInfo: ["URL?": userImageURL])
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    /// функция сбора запроса для получения картинки профиля пользователя
    private func makeUserProfileImageUrlRequest(token: String, url: String) -> URLRequest? {
        
        guard let url = URL(string: url) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeUserProfileImageUrlRequest: Ошибка сборки URL для запроса картинки профиля пользователя")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
