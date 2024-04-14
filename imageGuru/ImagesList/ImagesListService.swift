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
    /// структура ответа сервера для изменения Лайк-статуса фото
    private struct PhotoLikeModifyResult: Decodable {
        let photo: PhotoPageResult
    }
    
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
    private var changeLikeTask: URLSessionTask?
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
        guard let request = makeImageServiceRequest(url: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(photosPerPage)",
                                                    httpMethod: "GET"
        ) else {
            print("CONSOLE func fetchPhotosNextPage: Ошибка сборки запроса страницы с картинками")
            return
        }
        
        let task = dataLoader.objectTask(for: request) {(result: Result<[PhotoPageResult], Error>) in
            DispatchQueue.main.async {
                self.task = nil
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
                                                  createdAt: item.createdAt.convertToDate(),
                                                  welcomeDescription: item.description,
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
                    self.lastLoadedPage = nextPage
                    print("CONSOLE func fetchPhotosNextPage: Добавлено новых фото:", newPhotosAdded)
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
    }
    
    /// функция изменения статуса фото Лайк/Дизлайк
    func changeLike(photoIndex: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        assert(Thread.isMainThread)
        if changeLikeTask != nil {
            print("CONSOLE func changeLike: Отмена повторного сетевого запроса.")
            return
        }
        
        guard let request = makeImageServiceRequest(url: "https://api.unsplash.com/photos/\(photos[photoIndex].id)/like",
                                                    httpMethod: photos[photoIndex].isLiked ? "DELETE" : "POST"
        ) else {
            print("CONSOLE func changeLike: Ошибка сборки запроса")
            return
        }
        
        let changeLikeTask = dataLoader.objectTask(for: request) {(result: Result<PhotoLikeModifyResult, Error>) in
            DispatchQueue.main.async {
                self.changeLikeTask = nil
                switch result {
                case .success(let photoInfo):
                    self.photos[photoIndex].isLiked = photoInfo.photo.likedByUser
                    completion(.success(photoInfo.photo.likedByUser))
                    
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        }
        self.changeLikeTask = changeLikeTask
        changeLikeTask.resume()
    }
    
    /// функция очистки массива фотографий
    func cleanPhotos() {
        photos.removeAll()
        lastLoadedPage = nil
    }
    
    // MARK: - Private methods
    /// функция сбора запроса данных о фото
    private func makeImageServiceRequest(url: String, httpMethod: String) -> URLRequest? {
        guard let url = URL(string: url) else {
            assertionFailure("Failed to create URL")
            print("CONSOLE func makeImageServiceRequest: Ошибка сборки URL для запроса данных о фото")
            return nil
        }
        guard let token = OAuth2TokenStorage.token else {
            assertionFailure("Failed to get token from OAuth2TokenStorage")
            print("CONSOLE func makeImageServiceRequest: Ошибка получения токена от OAuth2TokenStorage")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = httpMethod
        return request
    }
}
