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
    var thumbImageURL: URL
    var largeImageURL: URL
    var isLiked: Bool
}

final class ImagesListService {
    
    // MARK: - Public Properties
    static let imagesListService = ImagesListService()
    var task: URLSessionTask?
    
    // MARK: - Private Properties
    /// структура для декодирования данных полученных от сервера
    private struct PhotoPageResult: Decodable {
        let id: String
        let createdAt: String
        let width: Int
        let height: Int
        let description: String?
        let urls: PhotoUrls
        let likedByUser: Bool
    }
    private struct PhotoUrls: Decodable {
        let full: String
        let thumb: String
    }
    
    /// кейсы возможных ошибок при запросе данных профиля пользователя
    private enum fetchPhotosNextPageErrors: Error {
        case requestCreationError
    }
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let dataLoader = DataLoader()
    
    private let photosPerPage = 10
    
    // MARK: - Initializers
    private init() { }
    
    // MARK: - Public methods
    /// функция запроса новой страницы с фото
    func fetchPhotosNextPage(completion: @escaping () -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            print("CONSOLE func fetchPhotosNextPage: Отмена повторного сетевого запроса.")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let requestUrl = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(photosPerPage)"
        guard let request = makeNextPageRequest(url: requestUrl) else {
            print("CONSOLE func fetchPhotosNextPage: Ошибка сборки запроса страницы с картинками")
            return
        }
        
        let task = dataLoader.objectTask(for: request) {(result: Result<[PhotoPageResult], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    var newPhotosAdded = 0
                    for item in list {
                        var itIsNew = true
                        if self.photos.count > 0 {
                            for oldPhoto in max(0, self.photos.count - self.photosPerPage) ..< self.photos.count {
                                if self.photos[oldPhoto].id == item.id {
                                    itIsNew.toggle()
                                    break
                                }
                            }
                        }
                        if itIsNew {
                            guard let thumbImageURL = URL(string: item.urls.thumb),
                                  let largeImageURL = URL(string: item.urls.full) else {
                                print("CONSOLE func fetchPhotosNextPage: Не удалось загрузить URL фото из ленты")
                                return
                            }
                            let newPhoto = Photo (id: item.id,
                                                  size: CGSize(width: item.width, height: item.height),
                                                  thumbImageURL: thumbImageURL,
                                                  largeImageURL: largeImageURL,
                                                  isLiked: item.likedByUser)
                            
                            self.photos.append(newPhoto)
                            newPhotosAdded += 1
                            NotificationCenter.default.post(name: .imageListUpdated,
                                                            object: self,
                                                            userInfo: ["ImageLoaded": newPhoto.id])
                        }
                    }
                    self.task = nil
                    self.lastLoadedPage = nextPage
                    print("CONSOLE func fetchPhotosNextPage: Добавлено ноывых фото: ", newPhotosAdded)
                    if nextPage == 1 {
                        completion()
                    }
                    
                case .failure(let error):
                    print("CONSOLE func fetchPhotosNextPage:", error.localizedDescription)
                    return
                }
            }
        }
        
        self.task = task
        task.resume()
    }

    /// функция изменения статуса фото Лайк/Дизлайк
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        //        let currentState =
    }
    
    // MARK: - Private methods
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
