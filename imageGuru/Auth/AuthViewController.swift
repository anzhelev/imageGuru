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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Overrided Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebWievControllerSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(showWebWievControllerSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
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
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        OAuth2Service.oAuth2Service.fetchOAuthToken(code) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    vc.dismiss(animated: true)
                    if let self {
                        self.delegate?.authViewController(self)
                    }
                case .failure(let error):
                    print("CONSOLE func fetchOAuthToken:", error.localizedDescription)
                    vc.dismiss(animated: true)
                }
            }
        }
    }
}
