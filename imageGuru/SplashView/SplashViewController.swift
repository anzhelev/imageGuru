//
//  SplashViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 16.03.2024.
//
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Visual Components
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let userProfile = ProfileService.profileService
    private let userPofileImage = ProfileImageService.profileImageService
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        userDataCheck()
    }
    
    // MARK: - Public Methods
    /// функция проверки наличия сохраненного токена и данных профиля пользователя
    func userDataCheck() {
        guard let token = oauth2TokenStorage.token else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            return
        }
        if userProfile.profile.username == "" {
            UIBlockingProgressHUD.show()
            userProfile.updateProfileDetails(userToken: token) {[self] in
                if userPofileImage.avatarURL == nil {
                    userPofileImage.updateProfileImageURL(userToken: token) { }
                }
                switchToTabBarController()
            }
        }
    }
    
    /// функция перехода на экран показа ленты фотографий
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    // MARK: - Overrided Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
    }
}
