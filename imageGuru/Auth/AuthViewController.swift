//
//  AuthViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 07.03.2024.
//
import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    // MARK: - Visual Components
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let showWebWievControllerSegueIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service.shared
    private let splashViewController = SplashViewController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Overrided Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebWievControllerSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebWievControllerSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    /// настраиваем кнопку навигации
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.igBlack
    }
    
    /// функция запроса токена с передачей авторизационного кода
    private func fetchOAuthToken(_ code: String) {
        oAuth2Service.fetchOAuthToken(code) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.oAuth2Service.task = nil
                    self?.oAuth2Service.lastCode = nil
                    OAuth2TokenStorage.token = token
                    self?.splashViewController.userDataCheck()
                case .failure(let error):
                    print("CONSOLE func fetchOAuthToken:", error.self)
                    OAuth2Service.authorizationFailed = true
                }
            }
        }
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self)
        fetchOAuthToken(code)
    }
}
