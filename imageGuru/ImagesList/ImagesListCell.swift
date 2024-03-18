//
//  ImagesListCell.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 13.02.2024.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IB Outlets
    @IBOutlet var gradientView: UIView!
    @IBOutlet var cellPicture: UIImageView!
    @IBOutlet var favoritesButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
}
