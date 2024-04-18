//
//  ProfileLogoutService.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 13.04.2024.
//
import Foundation
import WebKit
import Kingfisher

final class ProfileLogoutService {
    
    // MARK: - Public Properties
    static let profileLogoutService = ProfileLogoutService()
    
    // MARK: - Initializers
    private init() { }
    
    // MARK: - Public Methods
    func logout() {
        cleanCookies()
        cleanUserData()
        switchToSplashController()
    }
    
    // MARK: - Private Methods
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanUserData() {
        // удаляем токен
        OAuth2TokenStorage.token = nil
        
        // удаляем данные профиля
        ProfileService.profileService.cleanUserPofile()
        ProfileImageService.profileImageService.cleanUserAvatarURL()
        
        // удаляем данные о загруженных фото
        ImagesListService.imagesListService.cleanPhotos()
        let imageListViewController = ImagesListViewController()
        imageListViewController.cleanPhotos()
        
        // очищаем кэш KingFicher
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
    
    private func switchToSplashController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}
