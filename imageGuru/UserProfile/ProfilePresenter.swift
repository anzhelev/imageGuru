//
//  ProfilePresenter.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 22.04.2024.
//
import Foundation
import Kingfisher

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()    
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ProfileViewControllerProtocol?
    
    private let userProfile = ProfileService.profileService
    private let userPofileImageService = ProfileImageService.profileImageService
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Public Methods
    func viewDidLoad() {
        profileUpdate()
        if let url = userPofileImageService.avatarURL {
            updateUserImage(url: url)
        }
        else {
            userImageUrlUpdateMonitor()
        }
    }
    
    // MARK: - Private Methods
    /// функция загрузки и установки аватара с помощью KingFisher
    private func updateUserImage(url: URL) {
        guard let profileImageView = view?.profileImageView,
              let profileImageUnautorized = view?.profileImageUnautorized else {
            return
        }
        
        profileImageView.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(
            cornerRadius: 10000,
            backgroundColor: .igBlack
        )
        
        profileImageView.kf.setImage(
            with: url,
            placeholder: profileImageUnautorized,
            options: [.processor(processor)]
        )
    }
    
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
        self.profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: .userImageUrlUpdated,
            object: nil,
            queue: .main
        ) {[weak self] notification in
            let urlAsString = String(describing: notification.userInfo?["URL"] ?? "")
            guard let url = URL(string: urlAsString) else {
                print("CONSOLE func userImageUrlUpdateMonitor: Ошибка получения URL от NotificationCenter")
                return
            }
            self?.updateUserImage(url: url)
        }
    }
}
