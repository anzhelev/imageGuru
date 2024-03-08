//
//  AuthViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 07.03.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let showWebWievControllerSegueIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
        
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.igBlack
    }
    
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: process code
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
