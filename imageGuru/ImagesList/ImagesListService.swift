//
//  ImagesListService.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 06.04.2024.
//

import Foundation

/// структура для сохранения полученных данных о фото
struct Photo {
    var id: String
    var size: CGSize
    var createdAt: Date?
    var welcomeDescription: String?
    var thumbImageURL: String
    var largeImageURL: String
    var isLiked: Bool
}

final class ImagesListService {
 
    /// структура для декодирования данных полученных от сервера
    private struct PhotoPageResult: Decodable {
        let id: String
        let createdAt: Date
        let width: Int
        let height: Int
        let description: String
        let urls: PhotoUrls
    }
    private struct PhotoUrls: Decodable {
        let full: URL?
        let thumbs: URL?
    }
    
    /// кейсы возможных ошибок при запросе данных профиля пользователя
    private enum fetchPhotosNextPageErrors: Error {
        case requestCreationError
    }
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let dataLoader = DataLoader()
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil {
            print("CONSOLE func fetchPhotosNextPage: Отмена повторного сетевого запроса.")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        let requestUrl = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10"
        guard let request = makeNextPageRequest(url: requestUrl) else {
            print("CONSOLE func fetchPhotosNextPage: Ошибка сборки запроса страницы с картинками")
            return
        }
        
        let task = dataLoader.objectTask(for: request) {(result: Result<[PhotoPageResult], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    var newPhoto = Photo(id: "", size: .zero, thumbImageURL: "", largeImageURL: "", isLiked: false)
                    list.forEach {
                        let item = $0
                        newPhoto.id = item.id
                        newPhoto.size = CGSize(width: CGFloat(item.width), height: CGFloat(item.height))
                        newPhoto.createdAt = item.createdAt
                        newPhoto.welcomeDescription = item.description
                        newPhoto.thumbImageURL = String(describing: item.urls.thumbs)
                        newPhoto.largeImageURL = String(describing: item.urls.full)
                        self.photos.append(newPhoto)
                        self.lastLoadedPage = nextPage
                        NotificationCenter.default.post(name: .userImageUrlUpdated,
                                                        object: self,
                                                        userInfo: ["ImageLoaded": newPhoto.id])
                    }
                    //                completion(.success(userImageURL))
                    
                case .failure(let error):
                    //                completion(.failure(error))
                    return
                }
            }
        }
        
        self.task = task
        task.resume()
        

    }
    
    
    /// функция сбора запроса для получения следующей страницы списка картинок
    private func makeNextPageRequest(url: String) -> URLRequest? {
        
        guard let url = URL(string: url) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeNextPageRequest: Ошибка сборки URL для запроса страницы с картинками")
            return nil
        }
        guard let token = OAuth2TokenStorage.token else {
            assertionFailure("Failed to get token from OAuth2TokenStorage")
            print("CONSOLE func makeNextPageRequest: Ошибка получения токена от OAuth2TokenStorage")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
