//
//  AlertPresenter.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 30.03.2024.
//

import UIKit

/// модель для отображения алерта
struct AlertModel {
    let title: String
    let text: String
    let buttonText: String
    var completion: ((UIAlertAction) -> Void)? = nil
}

final class AlertPresenter {
    func showAlert(alert model: AlertModel, on screen: UIViewController) {
        let alert = UIAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        alert.addAction(action)
        screen.present(alert, animated: true, completion: nil)
    }
}
