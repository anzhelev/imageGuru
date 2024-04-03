//
//  File.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 16.03.2024.
//
import UIKit

final class CustomNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
