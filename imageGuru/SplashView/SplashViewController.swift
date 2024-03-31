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
    private let oAuth2Service = OAuth2Service.shared
    private let userProfile = ProfileService.profileService
    private let userPofileImage = ProfileImageService.profileImageService
    private let alertPresenter = AlertPresenter()
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oAuth2Service.authorizationFailed {
            showAlert(message: "Не удалось войти в систему")
            oAuth2Service.authorizationFailed.toggle()
        } else {
            userDataCheck()
        }
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
            userProfile.updateProfileDetails(userToken: token) {[self] result in
                switch result {
                case true:
                    if userPofileImage.avatarURL == nil {
                        userPofileImage.updateProfileImageURL(userToken: token) { }
                    }
                    switchToTabBarController()
                case false:
                    showAlert(message: "Не удалось получить данные профиля")
                }
            }
        } else {
            switchToTabBarController()
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
    /// подготовка перехода на экран авторизации
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
    
    // MARK: - Private Methods
    /// фукнкция отображения алерта об ошибке при авторизации или загрузке профиля
    private func showAlert(message: String) {
        let alert = AlertModel(title: "Что-то пошло не так(",
                               text: message,
                               buttonText: "Ok") {[self] UIAlertAction in
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
        self.alertPresenter.showAlert(alert: alert, on: self)
    }    
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
    }
}
