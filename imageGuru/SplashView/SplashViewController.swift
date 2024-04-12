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
    private let userProfile = ProfileService.profileService
    private let userPofileImage = ProfileImageService.profileImageService
    private let imagesListService = ImagesListService.imagesListService
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if OAuth2Service.authorizationFailed {
            showAlert(message: "Не удалось войти в систему")
            OAuth2Service.authorizationFailed.toggle()
        } else {
            userDataCheck()
        }
    }
    
    // MARK: - Public Methods
    /// функция проверки наличия сохраненного токена и данных профиля пользователя
    func userDataCheck() {
        guard let token = OAuth2TokenStorage.token else {
            switchToAuthViewController()
            return
        }
        if userProfile.profile.username == "" {
            UIBlockingProgressHUD.show()
            userProfile.updateProfileDetails(userToken: token) {[weak self] result in
                UIBlockingProgressHUD.dismiss()
                switch result {
                case true:
                    if self?.userPofileImage.avatarURL == nil {
                        self?.userPofileImage.updateProfileImageURL(userToken: token) { }
                    }
                    self?.imagesListService.fetchPhotosNextPage { [weak self] in
                        self?.switchToTabBarController()
                    }
                case false:
                    self?.showAlert(message: "Не удалось получить данные профиля")
                }
            }
        } else {
            imagesListService.fetchPhotosNextPage { [weak self] in
                self?.switchToTabBarController()
            }
        }
    }
    
    /// функция перехода на экран показа ленты фотографий
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
    
    // MARK: - Private Methods
    /// функция перехода на экран авторизации
    private func switchToAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CustomNavigationController") as UIViewController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    /// фукнкция отображения алерта об ошибке при авторизации или загрузке профиля
    private func showAlert(message: String) {
        let alert = AlertModel(title: "Что-то пошло не так(",
                               text: message,
                               buttonText: "Ok") {[self] UIAlertAction in
            switchToAuthViewController()
        }
        AlertPresenter.showAlert(alert: alert, on: self)
    }
    
    /// настраиваем внешний вид экрана и графические элементы
    private func configureUIElements() {
        view.backgroundColor = .igBlack
        let appLogoImage = UIImage(named: "launch_screen_logo")
        let appLogoImageView = UIImageView(image: appLogoImage)
        appLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appLogoImageView)
        
        NSLayoutConstraint.activate([
            appLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
    }
}
