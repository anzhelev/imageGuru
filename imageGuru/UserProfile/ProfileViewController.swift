//
//  ProfileViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.02.2024.
//
import Foundation
import UIKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    var profileImageView: UIImageView? { get set }
    var profileImageUnautorized: UIImage? { get set }
    func configureUIElements(userName: String, userLogin: String, userBio: String)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {

    // MARK: - Public Properties
    var presenter: ProfilePresenterProtocol?
    var profileImageView: UIImageView?
    var profileImageUnautorized: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
    }
    
    // MARK: - Public Methods
    /// настраиваем внешний вид экрана и графические элементы
    func configureUIElements(userName: String, userLogin: String, userBio: String) {
        view.backgroundColor = .igBlack
        let profileImageUnautorized = UIImage(named: "user_profile_picture_unautorized")
        let profileImageView = UIImageView(image: profileImageUnautorized)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        self.profileImageView = profileImageView
        self.profileImageUnautorized = profileImageUnautorized
        
        let userNameLabel = UILabel()
        userNameLabel.text = userName
        userNameLabel.font = UIFont(name: "SFPro-Bold", size: 23)
        userNameLabel.textColor = .igWhite
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userNameLabel)
        
        let userLoginLabel = UILabel()
        userLoginLabel.text = userLogin
        userLoginLabel.font = UIFont(name: "SFPro-Regular", size: 13)
        userLoginLabel.textColor = .igGray
        userLoginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userLoginLabel)
        
        let userDescriptionLabel = UILabel()
        userDescriptionLabel.text = userBio
        userDescriptionLabel.font = UIFont(name: "SFPro-Regular", size: 13)
        userDescriptionLabel.textColor = .igWhite
        userDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userDescriptionLabel)
        
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
    
    // MARK: - IBAction
    /// действие по нажатию кнопки выхода из профиля
    @objc func logoutButtonAction() {
        
        // показываем алерт
        let alert = AlertModel(title: "Чао какао!",
                               text: "Точно хотите выйти?",
                               buttonText: "Угу",
                               action: {_ in
            ProfileLogoutService.profileLogoutService.logout()
        },
                               secondButtonText: "Неа"
        )
        AlertPresenter.showAlert(alert: alert, on: self)
    }
}
