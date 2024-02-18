//
//  ImagesListCell.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 13.02.2024.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellPicture: UIImageView!
    @IBOutlet var favoritesButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
}
