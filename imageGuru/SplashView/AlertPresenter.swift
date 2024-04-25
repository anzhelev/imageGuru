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
    var action: ((UIAlertAction) -> Void)? = nil
    var secondButtonText: String? = nil
    var secondButtonAction: ((UIAlertAction) -> Void)? = nil
}

final class AlertPresenter {
    /// отображение алерта с одной или двумя кнопками согласно указанным параметрам модели
    static func showAlert(alert model: AlertModel, on screen: UIViewController) -> UIAlertController? {
        let alert = UIAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.action)
        alert.addAction(action)
        if let secondButtonText = model.secondButtonText {
            let secondButtonAction = UIAlertAction(title: secondButtonText, style: .default, handler: model.secondButtonAction)
            alert.addAction(secondButtonAction)
        }
        screen.present(alert, animated: true, completion: nil)
        return alert
    }
}
