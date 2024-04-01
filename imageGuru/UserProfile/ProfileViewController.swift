//
//  ProfileViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.02.2024.
//
import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private var profileImageView: UIImageView?
    private var userNameLabel: UILabel?
    private var userLoginLabel: UILabel?
    private var userDescriptionLabel: UILabel?
    private let userProfile = ProfileService.profileService
    private let userPofileImageService = ProfileImageService.profileImageService
//    private var userProfileImageURL: URL?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIElements()
//        userImageUpdateMonitor()
        
        self.profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: .userImageUrlUpdated,
            object: nil,
            queue: .main
        ) {[weak self] notification in
            self?.setUserImage(notification: notification)
        }
        
    }
    
    /// настраиваем внешний вид экрана и графические элементы
    private func configureUIElements() {
        view.backgroundColor = .igBackground
        let profileImage = UIImage(named: "user_profile_picture")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        self.profileImageView = profileImageView
        
        let userNameLabel = UILabel()
        if let userLastName = userProfile.profile.lastName {
            userNameLabel.text = "\(userProfile.profile.firstName) \(userLastName)"
        }
        else {
            userNameLabel.text = userProfile.profile.firstName
        }
        userNameLabel.font = UIFont(name: "SFPro-Bold", size: 23)
        userNameLabel.textColor = .igWhite
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userNameLabel)
        self.userNameLabel = userNameLabel
        
        let userLoginLabel = UILabel()
        userLoginLabel.text = userProfile.profile.loginName
        userLoginLabel.font = UIFont(name: "SFPro-Regular", size: 13)
        userLoginLabel.textColor = .igGray
        userLoginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userLoginLabel)
        self.userLoginLabel = userLoginLabel
        
        let userDescriptionLabel = UILabel()
        userDescriptionLabel.text = userProfile.profile.bio ?? "пусто"
        userDescriptionLabel.font = UIFont(name: "SFPro-Regular", size: 13)
        userDescriptionLabel.textColor = .igWhite
        userDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userDescriptionLabel)
        self.userDescriptionLabel = userDescriptionLabel
        
        let buttonImage = UIImage(named: "logoutButton")
        let labelDisableButton = UIButton.systemButton(with: buttonImage!, target: self, action: #selector(self.logoutButtonAction))
        labelDisableButton.tintColor = .igRed
        labelDisableButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelDisableButton)
        
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            userLoginLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userLoginLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            userDescriptionLabel.leadingAnchor.constraint(equalTo: userLoginLabel.leadingAnchor),
            userDescriptionLabel.topAnchor.constraint(equalTo: userLoginLabel.bottomAnchor, constant: 8),
            labelDisableButton.heightAnchor.constraint(equalToConstant: 44),
            labelDisableButton.widthAnchor.constraint(equalToConstant: 44),
            labelDisableButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            labelDisableButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14)
        ])
    }
    
    /// устанавливаем аватар
    private func setUserImage(notification: Notification) {
        print("CONSOLE func updateAvatar:", notification.userInfo as Any)
    }
    
    /// отслеживаем загрузку  аватара и запускаем его установку
    private func userImageUpdateMonitor() {
        self.profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: .userImageUrlUpdated,
            object: nil,
            queue: .main
        ) {[weak self] notification in
            self?.setUserImage(notification: notification)
        }
    }
    
    // MARK: - IBAction
    @objc func logoutButtonAction() {
        guard let profileImageView, let userNameLabel, let userLoginLabel, let userDescriptionLabel else {return}
        profileImageView.image = UIImage(named: "user_profile_picture_unautorized")
        userNameLabel.text = "User Name"
        userLoginLabel.text = "@user_login"
        userDescriptionLabel.text = "Description"
        
        NotificationCenter.default.post(name: .userImageUrlUpdated,
                                        object: self,
                                        userInfo: ["URL?": self.userPofileImageService.avatarURL ?? ""])
        
    }
}
