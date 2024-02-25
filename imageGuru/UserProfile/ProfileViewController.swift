//
//  ProfileViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 23.02.2024.
//
import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet var userProfilePhoto: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userLoginLabel: UILabel!
    @IBOutlet var userDescriptionLabel: UILabel!
    
    @IBAction func userLogoutButton(_ sender: Any) {
    }
    
}
