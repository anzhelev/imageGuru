//
//  ProfileViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.02.2024.
//
import UIKit

final class ProfileViewController: UIViewController {
    
    private var profileImageView: UIImageView?
    private var userNameLabel: UILabel?
    private var userLoginLabel: UILabel?
    private var userDescriptionLabel: UILabel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { // меняем цвет StatusBar на белый
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .igBackground
        
        let profileImage = UIImage(named: "user_profile_picture")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        self.profileImageView = profileImageView
        
        let userNameLabel = UILabel()
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        userNameLabel.textColor = .igWhite
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userNameLabel)
        self.userNameLabel = userNameLabel
        
        let userLoginLabel = UILabel()
        userLoginLabel.text = "@ekaterina_nov"
        userLoginLabel.font = .systemFont(ofSize: 13, weight: .regular)
        userLoginLabel.textColor = .igGray
        userLoginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userLoginLabel)
        self.userLoginLabel = userLoginLabel
        
        let userDescriptionLabel = UILabel()
        userDescriptionLabel.text = "Hello, world!"
        userDescriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
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
    
    @objc func logoutButtonAction() {
        guard let profileImageView, let userNameLabel, let userLoginLabel, let userDescriptionLabel else {return}
        profileImageView.image = UIImage(named: "user_profile_picture_unautorized")
        userNameLabel.text = "User Name"
        userLoginLabel.text = "@user_login"
        userDescriptionLabel.text = "Description"
    }
}
