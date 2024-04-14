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
        let profileImage: ImageSize
    }
    private struct ImageSize: Decodable{
        let small: URL?
        let medium: URL?
        let large: URL?
    }
    
    /// кейсы возможных ошибок при запросе данных профиля пользователя
    private enum FetchProfileImageUrlErrors: Error {
        case requestCreationError
    }
    
    private let userProfile = ProfileService.profileService
    private (set) var avatarURL: URL? {
        didSet {
            /// уведомляем ProfileViewController об обновлении ссылки на аватар пользователя
            if let avatarURL {
                NotificationCenter.default.post(name: .userImageUrlUpdated,
                                                object: self,
                                                userInfo: ["URL": avatarURL])
            }
        }
    }
    private let dataLoader = DataLoader()
    
    // MARK: - Initializers
    private init() { }
    
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
    
    /// удаляем инфо о ссылке на аватар пользователя
    func cleanUserAvatarURL () {
        avatarURL = nil
    }
    
    // MARK: - Private Methods
    
    /// функция получения url на фото профиля пользователя
    private func fetchUserProfileImageURL(username: String, token: String, completion: @escaping (Result<URL, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let userProfileImageRequestUrl = "https://api.unsplash.com/users/\(username)"
        guard let request = makeUserProfileImageUrlRequest(token: token, url: userProfileImageRequestUrl) else {
            completion(.failure(FetchProfileImageUrlErrors.requestCreationError))
            return
        }
        
        _ = dataLoader.objectTask(for: request) {(result: Result<ProfileImageURLRequestResult, Error>) in
            switch result {
            case .success(let url):
                guard let userImageURL = url.profileImage.large
                else {
                    return
                }
                completion(.success(userImageURL))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// функция сбора запроса для получения картинки профиля пользователя
    private func makeUserProfileImageUrlRequest(token: String, url: String) -> URLRequest? {
        
        guard let url = URL(string: url) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeUserProfileImageUrlRequest: Ошибка сборки URL для запроса аватара пользователя")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
