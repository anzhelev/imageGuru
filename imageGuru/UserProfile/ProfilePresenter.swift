//
//  ProfilePresenter.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 22.04.2024.
//
import Foundation

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func profileLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Properties
    private let userProfile = ProfileService.profileService
    private let userPofileImageService = ProfileImageService.profileImageService
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Public Methods
    func viewDidLoad() {
        profileUpdate()
        if let url = userPofileImageService.avatarURL {
            view?.updateUserImage(url: url)
        }
        else {
            userImageUrlUpdateMonitor()
        }
    }
    
    /// запускаем процедуру логаута
    func profileLogout() {
        ProfileLogoutService.profileLogoutService.logout()
    }
    
    // MARK: - Private Methods
    ///  заполняем профиль пользователя
    private func profileUpdate() {
        var userName: String
        if let userLastName = userProfile.profile.lastName {
            userName = "\(userProfile.profile.firstName) \(userLastName)"
        }
        else {
            userName = userProfile.profile.firstName
        }
        let userLogin = userProfile.profile.loginName
        let userBio = userProfile.profile.bio ?? ""
        
        view?.configureUIElements(userName: userName, userLogin: userLogin, userBio: userBio)
    }
    
    /// отслеживаем загрузку  аватара и запускаем его установку
    private func userImageUrlUpdateMonitor() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: .userImageUrlUpdated,
            object: nil,
            queue: .main) {[weak self] notification in
                let urlAsString = String(describing: notification.userInfo?["URL"] ?? "")
                guard let url = URL(string: urlAsString) else {
                    print("CONSOLE func userImageUrlUpdateMonitor: Ошибка получения URL от NotificationCenter")
                    return
                }
                self?.view?.updateUserImage(url: url)
            }
    }
}
